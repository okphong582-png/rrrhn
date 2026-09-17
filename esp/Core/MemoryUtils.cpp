#import "MemoryUtils.h"

#include <cerrno>
#include <cstdlib>
#include <cstring>

static void ReleaseGameTask() {
    if (get_task != MACH_PORT_NULL) {
        mach_port_deallocate(mach_task_self(), get_task);
        get_task = MACH_PORT_NULL;
    }
}

pid_t GetGameProcesspid(char* GameProcessName) {
    size_t length = 0;
    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0);
    
    if (err == -1) {
        err = errno;
    }
    
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if (procBuffer == NULL) {
            return -1;
        }
        
        err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, procBuffer, &length, NULL, 0);
        if (err == -1) {
            err = errno;
            free(procBuffer);
            return -1;
        }
        
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            pid_t Processpid = procBuffer[i].kp_proc.p_pid;
            
            if (strstr(procname, GameProcessName)) {
                free(procBuffer);
                return Processpid;
            }
        }
        
        free(procBuffer);
    }
    
    return -1;
}

vm_map_offset_t GetGameModule_Base(char* GameProcessName) {
    ReleaseGameTask();

    mach_vm_address_t vmoffset = 0;
    mach_vm_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr{};
    mach_msg_type_number_t vbrcount = VM_REGION_SUBMAP_INFO_COUNT_64;
    
    pid_t pid = GetGameProcesspid(GameProcessName);
    if (pid == -1) {
        return 0;
    }
    
    kern_return_t kret = task_for_pid(mach_task_self(), pid, &get_task);
    if (kret != KERN_SUCCESS || get_task == MACH_PORT_NULL) {
        ReleaseGameTask();
        return 0;
    }

    kern_return_t kr = mach_vm_region_recurse(get_task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
    if (kr == KERN_SUCCESS && vmoffset != 0) {
        return vmoffset;
    }

    ReleaseGameTask();
    return 0;
}

bool _read(long addr, void *buffer, int len)
{
    if (get_task == MACH_PORT_NULL || buffer == nullptr || len <= 0 || !isVaildPtr(addr)) return false;
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(get_task, (vm_address_t)addr, len, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != len)
    {
        return false;
    }
    return true;
}
