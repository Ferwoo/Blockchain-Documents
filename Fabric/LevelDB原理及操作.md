#              LevelDB原理及操作

## LevelDB之概览

　　LevelDB是Google传奇工程师[Jeff Dean](https://research.google.com/pubs/jeff.html)和[Sanjay Ghemawat](https://research.google.com/pubs/SanjayGhemawat.html)开源的KV存储引擎。 
　　了解原理之前首先要用起来，下面动手实现个例子：[安装调试](https://github.com/google/leveldb)(mac上直接命令行下[brew](https://brew.sh/) install leveldb即可安装，编译时候记得加上-lleveldb) 
　　example:

```
#include <assert.h>
#include <string.h>
#include <leveldb/db.h>
#include <iostream>

int main(int argc, char** argv)
{
    leveldb::DB* db;
    leveldb::Options options;
    // 如果打开已存在数据库的时候，需要抛出错误，将以下代码插在leveldb::DB::Open方法前面
    options.create_if_missing = true;
    // 打开一个数据库实例
    leveldb::Status status = leveldb::DB::Open(options, "/tmp/testdb", &db);
    assert(status.ok());
    // LevelDB提供了Put、Get和Delete三个方法对数据库进行添加、查询和删除
    std::string key = "key";
    std::string value = "value";
    // 添加key=value
    status = db->Put(leveldb::WriteOptions(), key, value);
    assert(status.ok());
    // 根据key查询value
    status = db->Get(leveldb::ReadOptions(), key, &value);
    assert(status.ok());
    std::cout<<value<<std::endl;
    // 修改操作（原生没有提供）由添加和删除合起来实现
    std::string key2 = "key2";
    // 添加key2=value
    status = db->Put(leveldb::WriteOptions(),key2,value);
    assert(status.ok());
    // 删除key
    status = db->Delete(leveldb::WriteOptions(), key);
    // 查询key2
    assert(status.ok());
    status = db->Get(leveldb::ReadOptions(), key2, &value);
    assert(status.ok());
    std::cout<<key2<<"=="<<value<<std::endl;
    // 查询key
    status = db->Get(leveldb::ReadOptions(), key, &value);
    if (!status.ok()) {
        std::cerr << key << ": " << status.ToString() << std::endl;
    } else {
        std::cout << key << "==" << value << std::endl;
    }
    delete db;
    return 0;
}12345678910111213141516171819202122232425262728293031323334353637383940414243444546
```

## 设计思路

　　LevelDB的数据是存储在磁盘上的，采用[LSM-Tree](http://ov6v82oa9.bkt.clouddn.com/download.pdf)的结构实现。LSM-Tree将磁盘的随机写转化为顺序写，从而大大提高了写速度。 
![1](http://oc3uwt4a5.bkt.clouddn.com/9092b78b-5c7a-37df-b9f2-fb8038bb79b9.jpg) 
　　为了做到这一点LSM-Tree的思路是将索引树结构拆成一大一小两颗树，较小的一个常驻内存，较大的一个持久化到磁盘，他们共同维护一个有序的key空间。 
![2](http://oc3uwt4a5.bkt.clouddn.com/7ece3749-415a-3083-893e-6859c9b9fc78.jpg) 
　　

  写入操作会首先操作内存中的树，随着内存中树的不断变大，会触发与磁盘中树的归并操作，而归并操作本身仅有顺序写。随着数据的不断写入，磁盘中的树会不断膨胀，为了避免每次参与归并操作的数据量过大，以及优化读操作的考虑，LevelDB将磁盘中的数据又拆分成多层，每一层的数据达到一定容量后会触发向下一层的归并操作，每一层的数据量比其上一层成倍增长。这也就是LevelDB的名称来源。

## 整体结构

内存数据的Memtable，分层数据存储的SST文件，版本控制的Manifest、Current文件，以及写Memtable前的WAL。

> WAL: `Write-Ahead Logging`预写日志系统 
> 数据库中一种高效的日志算法，对于非内存数据库而言，磁盘I/O操作是数据库效率的一大瓶颈。在相同的数据量下，采用WAL日志的数据库系统在事务提交时，磁盘写操作只有传统的回滚日志的一半左右，大大提高了数据库磁盘I/O操作的效率，从而提高了数据库的性能。

![img](http://oc3uwt4a5.bkt.clouddn.com/15037067311885.jpg) 
![整体结构.png](http://oc3uwt4a5.bkt.clouddn.com/0_1487308288666_TB1FFIRPpXXXXa9XVXXXXXXXXXX.png.png)

### Memtable：

　　对应Leveldb中的内存数据，LevelDB的写入操作会直接将数据写入到Memtable后返回。读取操作又会首先尝试从Memtable中进行查询，允许写入和读取。当Memtable写入的数据占用内存到达指定数量，则自动转换为Immutable Memtable，等待Dump到磁盘中，系统会自动生成新的Memtable供写操作写入新数据。 
　　LevelDB采用跳表SkipList实现，在给提供了O(logn)的时间复杂度的同时，又非常的易于实现： 
![SkipList](http://oc3uwt4a5.bkt.clouddn.com/0_1501291738687_5a9caa85-bfbb-4be0-9dc0-50c4474078f3-image.png.png) 
![SkipList](http://oc3uwt4a5.bkt.clouddn.com/15037076645668.jpg)

> 跳表作为一种数据结构通常用于取代平衡树，与红黑树不同的是，[skiplist](http://ov6v82oa9.bkt.clouddn.com/skiplist.pdf)对于树的平衡的实现是基于一种随机化的算法的，也就是说skiplist的插入和删除的工作是比较简单地。

　　SkipList中单条数据存放一条Key-Value数据，定义为：

```
SkipList Node := InternalKey + ValueString
InternalKey := KeyString + SequenceNum + Type
Type := kDelete or kValue
ValueString := ValueLength + Value
KeyString := UserKeyLength + UserKey12345
```

### Log文件

　　当应用写入一条Key:Value记录的时候，LevelDb会先往log文件里写入，成功后将记录插进Memtable中，这样基本就算完成了写入操作，Log文件在系统中的作用主要是用于系统崩溃恢复而不丢失数据，假如没有Log文件，因为写入的记录刚开始是保存在内存中的，此时如果系统崩溃，内存中的数据还没有来得及Dump到磁盘，所以会丢失数据（Redis就存在这个问题）。 
　　因为一次写入操作只涉及一次磁盘顺序写和一次内存写入，所以这是为何说LevelDb写入速度极快的主要原因。 
　　LevelDB首先将每条写入数据序列化为一个Record，单个Log文件中包含多个Record。同时，Log文件又划分为固定大小的Block单位，并保证Block的开始位置一定是一个新的Record。这种安排使得发生数据错误时，最多只需丢弃一个Block大小的内容。显而易见地，不同的Record可能共存于一个Block，同时，一个Record也可能横跨几个Block。 
![leveldb-log](http://oc3uwt4a5.bkt.clouddn.com/leveldb-log.png) 
![img](http://oc3uwt4a5.bkt.clouddn.com/15037110902017.jpg)
　　Log文件划分为固定长度的Block，由连续的32K为单位的物理Block构成的，每次读取的单位是以一个Block作为基本单位；每个Block中包含多个Record；Record的前56个位为Record头，包括32位checksum用做校验，16位存储Record实际内容数据的长度，8位的Type可以是Full、First、Middle或Last中的一种，表示该Record是否完整的在当前的Block中，如果Type不是Full，则通过Type指明其前后的Block中是否有当前Record的前驱后继。 
![leveldb-log2](http://oc3uwt4a5.bkt.clouddn.com/leveldb-log2.png)

```
Block := Record * N
Record := Header + Content
Header := Checksum + Length + Type
Type := Full or First or Midder or Last1234
```

### Immutable Memtable

　　当Memtable插入的数据占用内存到了一个界限后，需要将内存的记录导出到外存文件中，LevleDb会生成新的Log文件和Memtable，Memtable会变为Immutable，为之后向SST文件的归并做准备。顾名思义，Immutable Mumtable不再接受用户写入，只能读不能写入或者删除，同时会有新的Log文件和Memtable生成，LevelDb后台调度会将Immutable Memtable的数据导出到磁盘，形成一个新的SSTable文件。

### SST文件

　　SSTable就是由内存中的数据不断导出并进行**Compaction**操作(压缩操作，下文会讲到)后形成的，而且SSTable的所有文件是一种层级结构，第一层为Level 0，第二层为Level 1，依次类推，层级逐渐增高，这也是为何称之为LevelDb的原因。 
　　磁盘数据存储文件。分为`Level 0`到`Level N`多层，每一层包含多个SST文件；单个SST文件容量随层次增加成倍增长；文件内数据有序；其中`Level 0`的SST文件由Immutable直接Dump产生，其他Level的SST文件由其上一层的文件和本层文件归并产生；SST文件在归并过程中顺序写生成，生成后仅可能在之后的归并中被删除，而不会有任何的修改操作。 
　　SSTable中的文件是Key有序的，就是说在文件中小key记录排在大Key记录之前，各个Level的SSTable都是如此，但是这里需要注意的一点是：Level 0的SSTable文件（后缀为.sst）和其它Level的文件相比有特殊性：这个层级内的.sst文件，两个文件可能存在key重叠，比如有两个level 0的sst文件，文件A和文件B，文件A的key范围是：{bar, car}，文件B的Key范围是{blue,samecity}:

| level N | .sst  | max    | min        |
| ------- | ----- | ------ | ---------- |
| Level 0 | A.sst | “bar”  | “car”      |
| Level 0 | B.sst | “blue” | “samecity” |

　　那么很可能两个文件都存在key=”blood”的记录。对于其它Level的SSTable文件来说，则不会出现同一层级内。

#### SST文件的物理格式

　　LevelDb不同层级有很多SSTable文件（以后缀.sst为特征），所有.sst文件内部布局都是一样的。上节介绍Log文件是物理分块的，SSTable也一样会将文件划分为固定大小的物理存储块，但是两者逻辑布局大不相同，根本原因是：Log文件中的记录是Key无序的，即先后记录的key大小没有明确大小关系，而.sst文件内部则是根据记录的Key由小到大排列的。 
　　LevelDB将SST文件定义为Table，每个Table又划分为多个连续的Block，每个Block中又存储多条数据Entry： 
![SST文件的物理格式](http://oc3uwt4a5.bkt.clouddn.com/SST%E6%96%87%E4%BB%B6%E7%9A%84%E7%89%A9%E7%90%86%E6%A0%BC%E5%BC%8F.png) 
　　可以看出，单个Block作为一个独立的写入和解析单位，会在其末尾存储一个字节的**Type**和4个字节的**Crc**，其中Type记录的是当前Block的数据压缩策略（[Snappy压缩](https://github.com/google/snappy)或者无压缩两种），而Crc则存储Block中数据的校验信息。 
　　Block中每条数据**Entry**是以Key-Value方式存储的，并且是按Key有序存储，Leveldb很巧妙了利用了有序数组相邻Key可能有相同的Prefix的特点来减少存储数据量。如上图所示，每个Entry只记录自己的Key与前一个Entry Key的不同部分， 
　　在Entry开头记录三个长度值，分别是当前Entry和其之前Entry的公共Key Prefix长度、当前Entry Key自有Key部分的长度和Value的长度。通过这些长度信息和其后相邻的特有Key及Value内容，结合前一条Entry的Key内容，我们可以方便的获得当前Entry的完整Key和Value信息。 
![leveldb记录格式2](http://oc3uwt4a5.bkt.clouddn.com/leveldb%E8%AE%B0%E5%BD%95%E6%A0%BC%E5%BC%8F2.png)

> 例如要顺序存储Key值`“apple” = value1`和`“applepen” = value2`的两条数据，这里第二个Entry中，key共享长度为5，key非共享长度为3，value长度为6，key非共享内容为“pen”，value内容为“value2”.

　　这种方式非常好的减少了数据存储，但同时也引入一个风险，如果最开头的Entry数据损坏，其后的所有Entry都将无法恢复。为了降低这个风险，leveldb引入了**重启点**，每隔固定条数Entry会强制加入一个重启点，这个位置的Entry会完整的记录自己的Key，并将其shared值设置为0。同时，Block会将这些重启点的偏移量及个数记录在所有Entry后边的Tailer中。

#### SST文件的逻辑格式

　　Table中不同的Block物理上的存储方式一致，如上文所示，但在逻辑上可能存储不同的内容，包括存储数据的Block，存储索引信息的Block，存储Filter的Block： 
![leveldbssttable逻辑](http://oc3uwt4a5.bkt.clouddn.com/leveldbssttable%E9%80%BB%E8%BE%91.jpg)

- Data Block:![leveldb-datablock -w500](http://oc3uwt4a5.bkt.clouddn.com/leveldb-datablock.png) 
  从图中可以看出，其内部也分为两个部分，前面是一个个KV记录，其顺序是根据Key值由小到大排列的，在Block尾部则是一些“重启点”（Restart Point）,其实是一些指针，指出Block内容中的一些记录位置。
- Footer：为于Table尾部，记录指向Metaindex Block的Handle和指向Index Block的Handle。需要说明的是Table中所有的Handle是通过偏移量Offset以及Size一同来表示的，用来指明所指向的Block位置。Footer是SST文件解析开始的地方，通过Footer中记录的这两个关键元信息Block的位置，可以方便的开启之后的解析工作。另外Footer中还记录了用于验证文件是否为合法SST文件的常数值Magic num。
- Index Block：记录Data Block位置信息的Block，其中的每一条Entry指向一个Data Block，其Key值为所指向的Data Block最后一条数据的Key，Value为指向该Data Block位置的Handle。
- Metaindex Block：与Index Block类似，由一组Handle组成，不同的是这里的Handle指向的Meta Block。

```
Data Block：以Key-Value的方式存储实际数据，其中Key定义为：
DataBlock Key := UserKey + SequenceNum + Type 
//对比Memtable中的Key，可以发现Data Block中的Key并没有拼接UserKey的长度在UserKey前，
//这是由于上面讲到的物理结构中已经有了Key的长度信息。
Type := kDelete or kValue12345
```

- Meta Block：比较特殊的Block，用来存储元信息，目前LevelDB使用的仅有对布隆过滤器的存储。写入Data Block的数据会同时更新对应Meta Block中的过滤器。读取数据时也会首先经过布隆过滤器过滤。Meta Block的物理结构也与其他Block有所不同：

```
 [filter 0]
 [filter 1]
 [filter 2]
 ... 
 [filter N-1]
 [offset of filter 0] : 4 bytes
 [offset of filter 1] : 4 bytes
 [offset of filter 2] : 4 bytes
 ... 
 [offset of filter N-1] : 4 bytes
 [offset of beginning of offset array] : 4 bytes
 lg(base) : 1 byte123456789101112
```

其中每个filter节对应一段Key Range，落在某个Key Range的Key需要到对应的filter节中查找自己的过滤信息，base指定这个Range的大小。

### Manifest文件

　　Manifest文件中记录SST文件在不同Level的分布，单个SST文件的最大最小key，以及其他一些LevelDB需要的元信息。 
　　SSTable中的某个文件属于特定层级，而且其存储的记录是key有序的，那么必然有文件中的最小key和最大key，这是非常重要的信息，LevelDb应该记下这些信息。Manifest就是干这个的

### Current文件

　　从上面的介绍可以看出，LevelDB启动时的首要任务就是找到当前的Manifest，而Manifest可能有多个。Current文件简单的记录了当前Manifest的文件名，从而让这个过程变得非常简单。 
　　Current文件的内容只有一个信息，就是记载当前的manifest文件名。因为在LevleDb的运行过程中，随着Compaction的进行，SSTable文件会发生变化，会有新的文件产生，老的文件被废弃，Manifest也会跟着反映这种变化，此时往往会新生成Manifest文件来记载这种变化，而Current则用来指出哪个Manifest文件才是我们关心的那个Manifest文件。

## 主要操作

### 读写操作

#### 写流程

　　LevelDB的写操作包括设置key-value和删除key两种。需要指出的是这两种情况在LevelDB的处理上是一致的，删除操作其实是向LevelDB插入一条标识为删除的数据。 
　　Memtable并不存在真正的删除操作，删除某个Key的Value在Memtable内是作为插入一条记录实施的，但是会打上一个Key的删除标记，真正的删除操作是Lazy的，会在以后的Compaction过程中去掉这个KV。 
![leveldb写入](http://oc3uwt4a5.bkt.clouddn.com/leveldb%E5%86%99%E5%85%A5.png) 
　　从图中可以看出，对于一个插入操作Put(Key,Value)来说，完成插入操作包含两个具体步骤： 
　　首先是将这条KV记录以顺序写的方式追加到之前介绍过的log文件末尾，因为尽管这是一个磁盘读写操作，但是文件的顺序追加写入效率是很高的，所以并不会导致写入速度的降低； 
　　第二个步骤是:如果写入log文件成功，那么将这条KV记录插入内存中的Memtable中，前面介绍过，Memtable只是一层封装，其内部其实是一个Key有序的SkipList列表，插入一条新记录的过程也很简单，即先查找合适的插入位置，然后修改相应的链接指针将新记录插入即可。完成这一步，写入记录就算完成了。 
　　所以一个插入记录操作涉及一次磁盘文件追加写和内存SkipList插入操作，这是为何levelDb写入速度如此高效的根本原因。 
　　LevelDb的接口没有直接支持更新操作的接口，如果需要更新某个Key的Value,你可以选择直接生猛地插入新的KV，保持Key相同，这样系统内的key对应的value就会被更新；或者你可以先删除旧的KV， 之后再插入新的KV，这样比较委婉地完成KV的更新操作。

#### 读流程

　　![leveldb读取](http://oc3uwt4a5.bkt.clouddn.com/leveldb%E8%AF%BB%E5%8F%96.png)

　　首先，生成内部查询所用的Key，用生成的Key，依次尝试从 Memtable，Immtable以及SST文件中读取，直到找到（或者查到最高level，查找失败，说明整个系统中不存在这个Key)。 
　　从信息的更新时间来说，很明显Memtable存储的是最新鲜的KV对；Immutable Memtable中存储的KV数据对的新鲜程度次之；而所有SSTable文件中的KV数据新鲜程度一定不如内存中的Memtable和Immutable Memtable的。对于SSTable文件来说，如果同时在level L和Level L+1找到同一个key，level L的信息一定比level L+1的要新。也就是说，上面列出的查找路径就是按照数据新鲜程度排列出来的，越新鲜的越先查找。

> 举个例子。比如我们先往levelDb里面插入一条数据 `{key="www.samecity.com" value="我们"}`,过了几天，samecity网站改名为：69同城，此时我们插入数据`{key="www.samecity.com" value="69同城"}`，同样的key,不同的value；逻辑上理解好像levelDb中只有一个存储记录，即第二个记录，但是在levelDb中很可能存在两条记录，即上面的两个记录都在levelDb中存储了，此时如果用户查询`key="www.samecity.com"`,我们当然希望找到最新的更新记录，也就是第二个记录返回，这就是为何要优先查找新鲜数据的原因。

　　从SST文件中查找需要依次尝试在每一层中读取，得益于Manifest中记录的每个文件的key区间，我们可以很方便的知道某个key是否在文件中。`Level 0`的文件由于直接由Immutable Dump 产生，不可避免的会相互重叠，所以需要对每个文件依次查找。对于其他层次，由于归并过程保证了其互相不重叠且有序，二分查找的方式提供了更好的查询效率。 
　　可以看出同一个Key出现在上层的操作会屏蔽下层的。也因此删除Key时只需要在Memtable压入一条标记为删除的条目即可。被其屏蔽的所有条目会在之后的归并过程中清除。 
　　相对写操作，读操作处理起来要复杂很多，所以写的速度必然要远远高于读数据的速度，也就是说，LevelDb比较适合写操作多于读操作的应用场合。而如果应用是很多读操作类型的，那么顺序读取效率会比较高，因为这样大部分内容都会在缓存中找到，尽可能避免大量的随机读取操作。

##### levelDb中的Cache

　　读取操作如果没有在内存的memtable中找到记录，要多次进行磁盘访问操作。假设最优情况，即第一次就在level 0中最新的文件中找到了这个key，那么也需要读取2次磁盘，一次是将SSTable的文件中的index部分读入内存，这样根据这个index可以确定key是在哪个block中存储；第二次是读入这个block的内容，然后在内存中查找key对应的value。 
　　levelDb中引入了两个不同的Cache： Table Cache 和 Block Cache。其中Block Cache是配置可选的，即在配置文件中指定是否打开这个功能。

![leveldb table cache](http://oc3uwt4a5.bkt.clouddn.com/leveldb%20table%20cache.png)

　　在Cache中，key值是SSTable的文件名称，Value部分包含两部分，一个是指向磁盘打开的SSTable文件的文件指针，这是为了方便读取内容；另外一个是指向内存中这个SSTable文件对应的Table结构指针，table结构在内存中，保存了SSTable的index内容以及用来指示block cache用的cache_id ,当然除此外还有其它一些内容。 
　　比如在get(key)读取操作中，如果levelDb确定了key在某个level下某个文件A的key range范围内，那么需要判断是不是文件A真的包含这个KV。此时，levelDb会首先查找Table Cache，看这个文件是否在缓存里，如果找到了，那么根据index部分就可以查找是哪个block包含这个key。如果没有在缓存中找到文件，那么打开SSTable文件，将其index部分读入内存，然后插入Cache里面，去index里面定位哪个block包含这个Key 。如果确定了文件哪个block包含这个key，那么需要读入block内容，这是第二次读取。

| File  cache_id + block_offset | block内容 |
| ----------------------------- | --------- |
| File  cache_id + block_offset | block内容 |
| File  cache_id + block_offset | block内容 |
| File  cache_id + block_offset | block内容 |

　　Block Cache是为了加快这个过程的，如上图。其中的key是文件的cache_id加上这个block在文件中的起始位置block_offset。而value则是这个Block的内容。 
　　如果levelDb发现这个block在block cache中，那么可以避免读取数据，直接在cache里的block内容里面查找key的value就行，如果没找到呢？那么读入block内容并把它插入block cache中。levelDb就是这样通过两个cache来加快读取速度的。 
　　从这里可以看出，如果读取的数据局部性比较好，也就是说要读的数据大部分在cache里面都能读到，那么读取效率应该还是很高的，而如果是对key进行顺序读取效率也应该不错，因为一次读入后可以多次被复用。但是如果是随机读取，您可以推断下其效率如何。

### 压缩操作

　　为了加快读取速度，levelDb采取了compaction的方式来对已有的记录进行整理压缩，通过这种方式，来删除掉一些不再有效的KV数据，减小数据规模，减少文件数量等。 
　　数据压缩是LevelDB中重要的部分，即上文提到的归并。冷数据会随着Compaction不断的下移，同时过期的数据也会在合并过程中被删除。 
　　LevelDB的压缩操作由单独的后台线程负责。这里的Compaction包括两个部分，Memtable向Level 0 SST文件的Compaction，以及SST文件向下层的Compaction。 
　　levelDb的compaction机制和过程与Bigtable所讲述的是基本一致的，Bigtable中讲到三种类型的compaction: minor ，major和full。所谓minor Compaction，就是把memtable中的数据导出到SSTable文件中；major compaction就是合并不同层级的SSTable文件，而full compaction就是将所有SSTable进行合并。 
　　LevelDb包含其中两种，minor和major。

#### minor compaction

　　Minor compaction 的目的是当内存中的memtable大小到了一定值时，将内容保存到磁盘文件中：

![leveldb-minor compaction](http://oc3uwt4a5.bkt.clouddn.com/leveldb-minor%20compaction.png)

　　当memtable数量到了一定程度会转换为immutable memtable，此时不能往其中写入记录，只能从中读取KV内容。之前介绍过，immutable memtable其实是一个多层级队列SkipList，其中的记录是根据key有序排列的。所以这个minor compaction实现起来也很简单，就是按照immutable memtable中记录由小到大遍历，并依次写入一个level 0的新建SSTable文件中，写完后建立文件的index数据，这样就完成了一次minor compaction。 
　　**CompactMemTable函数**会将Immutable中的数据整体Dump为`Level 0`的一个文件，这个过程会在Immutable Memtable存在时被Compaction后台线程调度。 
　　过程比较简单，首先会获得一个Immutable的Iterator用来遍历其中的所有内容，创建一个新的Level 0 SST文件，并将Iterator读出的内容依次顺序写入该文件。之后更新元信息并删除Immutable Memtable。

#### major compaction

　　当某个level下的SSTable文件数目超过一定设置值后，levelDb会从这个level的SSTable中选择一个文件（level>0），将其和高一层级的level+1的SSTable文件合并，这就是major compaction。 
　　我们知道在大于0的层级中，每个SSTable文件内的Key都是由小到大有序存储的，而且不同文件之间的key范围（文件内最小key和最大key之间）不会有任何重叠。Level 0的SSTable文件有些特殊，尽管每个文件也是根据Key由小到大排列，但是因为level 0的文件是通过minor compaction直接生成的，所以任意两个level 0下的两个sstable文件可能再key范围上有重叠。所以在做major compaction的时候，对于大于level 0的层级，选择其中一个文件就行，但是对于level 0来说，指定某个文件后，本level中很可能有其他SSTable文件的key范围和这个文件有重叠，这种情况下，要找出所有有重叠的文件和level 1的文件进行合并，即level 0在进行文件选择的时候，可能会有多个文件参与major compaction。 
　　同层的文件轮流来compaction，比如这次是文件A进行compaction，那么下次就是在key range上紧挨着文件A的文件B进行compaction，这样每个文件都会有机会轮流和高层的level 文件进行合并。如果选好了level L的文件A和level L+1层的文件进行合并，那么问题又来了，应该选择level L+1哪些文件进行合并？levelDb选择L+1层中和文件A在key range上**有重叠的所有文件**来和文件A进行合并。 
　　 
![leveldbSSTable Compaction](http://oc3uwt4a5.bkt.clouddn.com/leveldbSSTable%20Compaction.png)

　　Major compaction的过程如下：对多个文件采用**多路归并排序**的方式，依次找出其中最小的Key记录，也就是对多个文件中的所有记录重新进行排序。之后采取一定的标准判断这个Key是否还需要保存，如果判断没有保存价值，那么直接抛掉，如果觉得还需要继续保存，那么就将其写入level L+1层中新生成的一个SSTable文件中。就这样对KV数据一一处理，形成了一系列新的L+1层数据文件，之前的L层文件和L+1层参与compaction 的文件数据此时已经没有意义了，所以全部删除。这样就完成了L层和L+1层文件记录的合并过程。 
　　那么在major compaction过程中，判断一个KV记录是否抛弃的标准是什么呢？其中一个标准是:对于某个key来说，如果在小于L层中存在这个Key，那么这个KV在major compaction过程中可以抛掉。因为我们前面分析过，对于层级低于L的文件中如果存在同一Key的记录，那么说明对于Key来说，有更新鲜的Value存在，那么过去的Value就等于没有意义了，所以可以删除。 
　　**BackgroundCompaction函数** 
　　SST文件的Compaction可以由用户通过接口手动发起，也可以自动触发。LevelDB中触发SST Compaction的因素包括Level 0 SST的个数，其他Level SST文件的总大小，某个文件被访问的次数。Compaction线程一次Compact的过程如下：

- 首先根据触发Compaction的原因以及维护的相关信息找到本次要Compact的一个SST文件。对于`Level 0`的文件比较特殊，由于`Level 0`的SST文件由Memtable在不同时间Dump而成，所以可能有Key重叠。因此除该文件外还需要获得所有与之重叠的`Level 0`文件。这时我们得到一个包含一个或多个文件的文件集合，处于同一Level。
- SetupOtherInputs： 在Level+1层获取所有与当前的文件集合有Key重合的文件。
- DoCompactionWork：对得到的包含相邻两层多个文件的文件集合，进行归并操作并将结果输出到Level + 1层的一个新的SST文件，归并的过程中删除所有过期的数据。删除之前的文件集合里的所有文件。

通过上述过程我们可以看到，这个新生成的文件在其所在Level不会跟任何文件有Key的重叠。

## LevelDb 的特点：

1. 首先，LevelDb是一个持久化存储的KV系统，和Redis这种内存型的KV系统不同，LevelDb不会像Redis一样狂吃内存，而是将大部分数据存储到磁盘上。
2. 其次，LevelDb在存储数据时，是根据记录的key值有序存储的，就是说相邻的key值在存储文件中是依次顺序存储的，而应用可以自定义key大小比较函数，LevelDb会按照用户定义的比较函数依序存储这些记录。
3. 再次，像大多数KV系统一样，LevelDb的操作接口很简单，基本操作包括写记录，读记录以及删除记录。也支持针对多条操作的原子批量操作。
4. 另外，LevelDb支持数据快照(snapshot)功能，使得读取操作不受写操作影响，可以在读操作过程中始终看到一致的数据。
5. 除此外，LevelDb还支持数据压缩等操作，这对于减小存储空间以及增快IO效率都有直接的帮助。
6. LevelDb性能非常突出，官方网站报道其随机写性能达到40万条记录每秒，而随机读性能达到6万条记录每秒。总体来说，LevelDb的写操作要大大快于读操作，而顺序读写操作则大大快于随机读写操作。

<http://www.frankyang.cn/2017/09/04/%E5%8D%8A%E5%B0%8F%E6%97%B6%E5%AD%A6%E4%BC%9Aleveldb%E5%8E%9F%E7%90%86%E5%8F%8A%E5%BA%94%E7%94%A8/>

