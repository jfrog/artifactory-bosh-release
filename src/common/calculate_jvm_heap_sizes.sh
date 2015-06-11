
calculate_max_heap_size()
{
    case "`uname`" in
        Linux)
            system_memory_in_mb=`free -m | awk '/:/ {print $2;exit}'`
        ;;
        FreeBSD)
            system_memory_in_bytes=`sysctl hw.physmem | awk '{print $2}'`
            system_memory_in_mb=`expr $system_memory_in_bytes / 1024 / 1024`
        ;;
        SunOS)
            system_memory_in_mb=`prtconf | awk '/Memory size:/ {print $3}'`
        ;;
        *)
            # assume reasonable defaults for e.g. a modern desktop or
            # cheap server
            system_memory_in_mb="2048"
        ;;
    esac

    # set max heap size based on the following
    # max(min(1/2 ram, 1024MB), min(1/4 ram, 8GB))
    # calculate 1/2 ram and cap to 1024MB
    # calculate 1/4 ram and cap to 8192MB
    # pick the max
    echo "system memory in mb $system_memory_in_mb"
    half_system_memory_in_mb=`expr $system_memory_in_mb / 2`
    echo "system memory in mb $half_system_memory_in_mb"
    if [ "$half_system_memory_in_mb" -lt "1024" ]
    then
        half_system_memory_in_mb="1024"
    fi
    export MAX_HEAP_SIZE="${half_system_memory_in_mb}m"
}
