

###                                                                几种重要排序算法的Go语言实现



####                                                                                                               八大排序算法比较

![Single Validating Peer](images/20170601112918444.png)

![Single Validating Peer](images/排序算法.png)

*n为数字个数，r为基数（10），d为位数 
*稳定性：假定在待排序的记录序列中，存在多个具有相同的关键字的记录，若经过排序，这些记录的相对次序保持不变，即在原序列中，[i=rjri=rj，且riri在rjrj之前，而在排序后的序列中，riri仍在rjrj之前，则称这种排序算法是稳定的；否则称为不稳定的。

####时间复杂度：它定性描述了该算法的运行时间；

####空间复杂度：一个算法在运行过程中临时占用存储空间大小的量度。





**1、冒泡排序**

定义：它重复地走访过要排序的元素列，依次比较两个相邻的元素，如果他们的顺序（如从大到小、首字母从A到Z）错误就把他们交换过来。走访元素的工作是重复地进行直到没有相邻元素需要交换，也就是说该元素已经排序完成。

原理：1、比较相邻的元素。如果第一个比第二个大，就交换他们两个。
2、对每一对相邻元素做同样的工作，从开始第一对到结尾的最后一对。在这一点，最后3、的元素应该会是最大的数。
4、针对所有的元素重复以上的步骤，除了最后一个。
持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。



```
 1 func BubbleSort(vector []int) {
 2     fmt.Println("BubbleSort")
 3     fmt.Println(vector)
 4     for i := 0; i < len(vector); i++ {
 5         tag := true // 为了剪枝
 6         // 每一趟将最大的数冒泡
 7         for j := 0; j < len(vector)-i-1; j++ {
 8             if vector[j] > vector[j+1] { /*vector[j] < vector[j+1]*/
 9                 temp := vector[j]
10                 vector[j] = vector[j+1]
11                 vector[j+1] = temp
12                 tag = false
13             }
14         }
15         if tag {
16             break //0~len(vector)-i没有发生交换说明已经有序
17         }
18         fmt.Println(vector)
19     }
20 }
```



**2、插入排序**

定义：有一个已经有序的数据序列，要求在这个已经排好的数据序列中插入一个数，但要求插入后此数据序列仍然有序。

原理：每步将一个待排序的记录，按其关键码值的大小插入前面已经排序的文件中适当位置上，直到全部插入完为止。

```
 1 func InsertSort(vector []int) {
 2     fmt.Println("InsertSort")
 3     fmt.Println(vector)
 4     for i := 1; i < len(vector); i++ {
 5         // 每一趟不满足条件就选择i为哨兵保存，将哨兵插入0~i-1有序序列（0~i-1始终是有序的）
 6         if vector[i] < vector[i-1] { /*vector[i] > vector[i-1]*/
 7             temp := vector[i]
 8             //后移直到找到哨兵合适的位置
 9             j := i - 1
10             for ; j >= 0 && vector[j] > temp; j-- { /*vector[j] < temp*/
11                 vector[j+1] = vector[j]
12             }
13             //插入位置前后都是有序的，最后也是有序的
14             vector[j+1] = temp
15         }
16         fmt.Println(vector)
17     }
18 }
```



**3、选择排序**

原理：是每一次从待排序的[数据元素](https://baike.baidu.com/item/%E6%95%B0%E6%8D%AE%E5%85%83%E7%B4%A0/715313)中选出最小（或最大）的一个元素，存放在序列的起始位置，直到全部待排序的数据元素排完。

```
 1 func SelectSort(vector []int) {
 2     fmt.Println("SelectSort")
 3     fmt.Println(vector)
 4     for i := 0; i < len(vector); i++ {
 5         // 选择最小的元素
 6         k := i
 7         for j := i + 1; j < len(vector); j++ {
 8             if vector[k] > vector[j] {
 9                 k = j
10             }
11         }
12         // 交换
13         if k != i {
14             temp := vector[i]
15             vector[i] = vector[k]
16             vector[k] = temp
17         }
18         fmt.Println(vector)
19     }
20 }
```



**4、二元选择排序**

原理：而二元选择排序,从待排序数组中选择一个最大值,和一个最小值,分别与第一个和最后一个元素进行交换,这样就使选择排序的时间复杂度能够降低。

```
 1 func BinarySelectSort(vector []int) {
 2     fmt.Println("SelectSort")
 3     fmt.Println(vector)
 4     n := len(vector)
 5     for i := 0; i < n/2; i++ {
 6         // 选择最小的元素和最大元素
 7         k := i
 8         t := n - i - 1
 9         for j := i + 1; j <= n-i-1; j++ {
10             if vector[k] > vector[j] {
11                 k = j
12             }
13             if vector[t] < vector[j] {
14                 t = j
15             }
16         }
17         // 交换
18         if k != i {
19             temp := vector[i]
20             vector[i] = vector[k]
21             vector[k] = temp
22         }
23         if t != n-i-1 {
24             temp := vector[n-i-1]
25             vector[n-i-1] = vector[t]
26             vector[t] = temp
27         }
28         fmt.Println(vector)
29     }
30 }
```



**5、快速排序**

快速排序（Quicksort）是对[冒泡排序](https://baike.baidu.com/item/%E5%86%92%E6%B3%A1%E6%8E%92%E5%BA%8F/4602306)的一种改进，公认效率最好。

原理：通过一趟排序将要排序的数据分割成独立的两部分，其中一部分的所有数据都比另外一部分的所有数据都要小，然后再按此方法对这两部分数据分别进行快速排序，整个排序过程可以[递归](https://baike.baidu.com/item/%E9%80%92%E5%BD%92/1740695)进行，以此达到整个数据变成有序[序列](https://baike.baidu.com/item/%E5%BA%8F%E5%88%97/1302588)。

```
 1 func QuickSort(vector []int, low, hight int) {
 2     fmt.Println(vector)
 3     if low < hight {
 4         i := low
 5         j := hight
 6         temp := vector[low] // 开始挖坑填数
 7         for i < j {
 8             for i < j && vector[j] >= temp {
 9                 j--
10             }
11             vector[i] = vector[j]
12             for i < j && vector[i] <= temp {
13                 i++
14             }
15             vector[j] = vector[i]
16         }
17         vector[i] = temp
18         QuickSort(vector, low, i-1) // 分治
19         QuickSort(vector, i+1, hight)
20     }
21 }
```



**6、希尔排序**

**希尔排序**(Shell's Sort)是[插入排序](https://baike.baidu.com/item/%E6%8F%92%E5%85%A5%E6%8E%92%E5%BA%8F)的一种又称“缩小增量排序”（Diminishing Increment Sort），是直接插入排序算法的一种更高效的改进版本。

希尔排序是把记录按下标的一定增量分组，对每组使用直接插入排序算法排序；随着增量逐渐减少，每组包含的关键词越来越多，当增量减至1时，整个文件恰被分成一组，[算法](https://baike.baidu.com/item/%E7%AE%97%E6%B3%95/209025)便终止。

```+go
func ShellSort(a []int) {
    n := len(a)
    h := 1
    for h < n/3 { //寻找合适的间隔h
        h = 3*h + 1
    }
    for h >= 1 {
        //将数组变为间隔h个元素有序
        for i := h; i < n; i++ {
            //间隔h插入排序
            for j := i; j >= h && a[j] < a[j-h]; j -= h {
                swap(a, j, j-h)
            }
        }
        h /= 3
    }
}
 
func swap(slice []int, i int, j int) {
    slice[i], slice[j] = slice[j], slice[i]
}

```



**7、归并排序**

原理：将待排序序列R[0...n-1]看成是n个长度为1的有序序列，将相邻的有序表成对归并，得到n/2个长度为2的有序表；将这些有序序列再次归并，得到n/4个长度为4的有序序列；如此反复进行下去，最后得到一个长度为n的有序序列。

归并排序其实要做两件事：

（1）“分解”——将序列每次折半划分。
（2）“合并”——将划分后的序列段两两合并后排序。

归并操作(merge)，也叫归并算法，指的是将两个顺序序列合并成一个顺序序列的方法。

```+go
package main
    
import "fmt"
    
func merge(arr []int, l int, mid int, r int) {
    temp := make([]int, r-l+1)
    for i := l; i <= r; i++ {
        temp[i-l] = arr[i]
    }
    
    left := l
    right := mid + 1
    
    for i := l; i <= r; i++ {
        if left > mid {
            arr[i] = temp[right-l]
            right++
        } else if right > r {
            arr[i] = temp[left-l]
            left++
        } else if temp[left - l] > temp[right - l] {
            arr[i] = temp[right - l]
            right++
        } else {
            arr[i] = temp[left - l]
            left++
        }
    }
}
    
func MergeSort(arr []int, l int, r int) {
    // 第二步优化，当数据规模足够小的时候，可以使用插入排序
    if r - l <= 15 {
        // 对 l,r 的数据执行插入排序
        for i := l + 1; i <= r; i++ {
            temp := arr[i]
            j := i
            for ; j > 0 && temp < arr[j-1]; j-- {
                arr[j] = arr[j-1]
            }
            arr[j] = temp
        }
        return
    }
    
    mid := (r + l) / 2
    MergeSort(arr, l, mid)
    MergeSort(arr, mid+1, r)
    
    // 第一步优化，左右两部分已排好序，只有当左边的最大值大于右边的最小值，才需要对这两部分进行merge操作
    if arr[mid] > arr[mid + 1] {
        merge(arr, l, mid, r)
    }
}
    
func main() {
    arr := []int{3, 1, 2, 5, 6, 43, 4}
    MergeSort(arr, 0, len(arr)-1)
    
    fmt.Println(arr)
}
```



**8、堆排序**

原理：堆排序(Heapsort)是指利用堆积树（堆）这种[数据结构](https://baike.baidu.com/item/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84/1450)所设计的一种[排序算法](https://baike.baidu.com/item/%E6%8E%92%E5%BA%8F%E7%AE%97%E6%B3%95/5399605)，它是选择排序的一种。可以利用[数组](https://baike.baidu.com/item/%E6%95%B0%E7%BB%84/3794097)的特点快速定位指定索引的元素。堆分为大根堆和小根堆，是**完全二叉树**。大根堆的要求是每个节点的值都不大于其父节点的值，即**A[PARENT[i]] >= A[i]。**在数组的非降序排序中，需要使用的就是大根堆，因为根据大根堆的要求可知，最大的值一定在堆顶。

```+go
package main

import (
    "fmt"
    "math/rand"
)

func main() {
    var length = 20
    var tree []int

    for i := 0; i < length; i++ {
        tree = append(tree, int(rand.Intn(1000)))
    }
    fmt.Println(tree)

    // 此时的切片o可以理解为初始状态二叉树的数(qie)组(pian)表示，然后需要将这个乱序的树调整为大根堆的状态
    // 由于是从树的右下角第一个非叶子节点开始从右向左从下往上进行比较，所以可以知道是从n/2-1这个位置的节点开始算
    for i := length/2 - 1; i >= 0; i-- {
        nodeSort(tree, i, length-1)
    }

    // 次数tree已经是个大根堆了。只需每次交换根节点和最后一个节点，并减少一个比较范围。再进行一轮比较
    for i := length - 1; i > 0; i-- {
        // 如果只剩根节点和左孩子节点，就可以提前结束了
        if i == 1 && tree[0] <= tree[i] {
            break
        }
        // 交换根节点和比较范围内最后一个节点的数值
        tree[0], tree[i] = tree[i], tree[0]
        // 这里递归的把较大值一层层提上来
        nodeSort(tree, 0, i -1)
        fmt.Println(tree)
    }
}
func nodeSort(tree []int, startNode, latestNode int) {
    var largerChild int
    leftChild := startNode*2 + 1
    rightChild := leftChild + 1

    // 子节点超过比较范围就跳出递归
    if leftChild >= latestNode {
        return
    }

    // 左右孩子节点中找到较大的，右孩子不能超出比较的范围
    if rightChild <= latestNode && tree[rightChild] > tree[leftChild] {
        largerChild = rightChild
    } else {
        largerChild = leftChild
    }

    // 此时startNode节点数值已经最大了，就不用再比下去了
    if tree[largerChild] <= tree[startNode] {
        return
    }

    // 到这里发现孩子节点数值比父节点大，所以交换位置，并继续比较子孙节点，直到把大鱼捞上来
    tree[startNode], tree[largerChild] = tree[largerChild], tree[startNode]
    nodeSort(tree, largerChild, latestNode)
}
```



**9、基数排序**

原理：[基数排序](https://baike.baidu.com/item/%E5%9F%BA%E6%95%B0%E6%8E%92%E5%BA%8F/7875498)（radix sort）属于“分配式排序”（distribution sort），又称“桶子法”（bucket sort）或bin sort，顾名思义，它是透过键值的部份资讯，将要排序的[元素分配](https://baike.baidu.com/item/%E5%85%83%E7%B4%A0%E5%88%86%E9%85%8D/2107419)至某些“桶”中，藉以达到排序的作用，基数排序法是属于稳定性的排序，其[时间复杂度](https://baike.baidu.com/item/%E6%97%B6%E9%97%B4%E5%A4%8D%E6%9D%82%E5%BA%A6/1894057)为O (nlog(r)m)，其中r为所采取的基数，而m为堆数，在某些时候，基数排序法的效率高于其它的稳定性排序法。

```+go
package main
import "strconv"
func RadixSort(arr []int) []int{
    if len(arr)<2{
        fmt.Println("NO NEED TO SORT"）
        return arr
    }
    maxl:=MaxLen(arr)
    return RadixCore(arr,0,maxl)
}
func RadixCore(arr []int,digit,maxl int) []int{   //核心排序机制时间复杂度 O( d( r+n ) )
    if digit>=maxl{
        return arr                                               //排序稳定
    }
    radix:=10
    count:=make([]int,radix)
    bucket:=make([]int,len(arr))
    for i:=0;i<len(arr);i++{
        count[GetDigit(arr[i],digit)]++
    }
    for i:=1;i<radix;i++{
        count[i]+=count[i-1]
    }
    for i:=len(arr)-1;i>=0;i--{
        d:=GetDigit(arr[i],digit)
        bucket[count[d]-1]=arr[i]
        count[d]--
    }
    return RadixCore(bucket,digit+1,maxl)
}
func GetDigit(x,d int) int{                          //获取某位上的数字
    a:=[]int{1,10,100,1000,10000,100000,1000000}
    return (x/a[d])%10
}
func MaxLen(arr []int) int{                 //获取最大位数
    var maxl,curl int
    for i:=0;i<len(arr);i++{
        curl=len(strconv.Itoa(arr[i]))
        if curl>maxl{
            maxl=curl
        }
    }
    return maxl
}

```

