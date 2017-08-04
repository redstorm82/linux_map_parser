# linux_map_parser
a lua project to parse linux /proc/pid/maps file ,and android bionic libc.debug.malloc  dumpheap  mm file 
 
使用说明：
本工程主要用于处理android native 内存泄漏问题代码调用堆栈分析。
需要的输入文件有两个：
1.待分析的程序对应的.map文件，通过cat /proc/进程pid/maps > 进程名.map
2.使用android bionic库的libc.debug.malloc方式获取到的调用堆栈，进程名.map.mm，典型的获取方法如下：
   0）准备工作
    #adb remount
    #adb shell
    #echo "libc.debug.malloc=1">> /system/build.prop
    #sync
    重启板子，通过串口查看是否已成功加载malloc库，表示已正常加载
   调试安卓系统服务内存泄漏，具体步骤如下：
   1）保存 /proc/<pid>/maps文件到PC机器
   2）  dumpsys media.player -m > /data/1.mm  
   3） 操作程序
   4）  dumpsys media.player -m > /data/2.mm  
   调试应用内存泄漏具体步骤如下：
    1. 保存 /proc/<pid>/maps文件到PC机器
    2. am dumpheap -n  <应用的包名>  1.mm （eg： am dumpheap -n com.xxx.launcher /data/1.mm  ）
    3. 操作程序
    4. am dumpheap -n  <应用的包名>  2.mm
    
    然后比较1.mm和2.mm，看看2比1多了那些内容
    对比结果如下。可以发现，倒数第二行比较明显，堆栈的情况如
    上面两次退出到首页后，抓的信息，通过对比，可以发现红框内的增长比较明显。
    size     4112, dup   31, 0xb3d3501a, 0xb3d352e8,0xb6eaecfe, 0xb5010238, 0xb4b46c4c, 0xb4b300a8, 0xb4b30f98, 0xb4b171f0, 0xb4b1fa14
   需重点分析此处堆栈，将本行内容存到 进程名.map.mm 文件中。
   
 本工程用法，将map文件(map_file_name)和对应的要分析的.mm文件（mm_file_name）保存在同一个目录下，使用下面命令，即可得到分析后的堆栈信息map_file_name.parsed
 lua main.lua map_file_name mm_file_name
 
