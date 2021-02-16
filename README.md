# InvokeBuildSubTasks

`deploy` subtasks

    .\root.build.ps1 deploy [tab]

    task1
    deploy-task2
    .

`build` subtasks

    .\root.build.ps1 build [tab]

    task1
    build-task2
    .

`deploy` sub parameters

    .\root.build.ps1 deploy task1 -[tab]

    RootParam1
    DeployParam1
    DeployParam2

`build` sub parameters

    .\root.build.ps1 build task1 -[tab]

    RootParam1
    BuildParam1
    BuildParam2


This works:

    root.build.ps1 build, deploy task1 -CommonChildParam zzz

with output

```
Build build, deploy C:\-\InvokeBuildSubTasks\root.build.ps1
Task /build
Build task1 C:\-\InvokeBuildSubTasks\src\build.build.ps1
Task /task1
child 1 task 1  zzz
Done /task1 00:00:00.0070356
Build succeeded. 1 tasks, 0 errors, 0 warnings 00:00:00.0560018
Done /build 00:00:00.0789647
Task /deploy
Build task1 C:\-\InvokeBuildSubTasks\deploy\deploy.build.ps1
Task /task1
child 2 task 1  zzz
Done /task1 00:00:00.0060003
Build succeeded. 1 tasks, 0 errors, 0 warnings 00:00:00.0189746
Done /deploy 00:00:00.0259660
Build succeeded. 4 tasks, 0 errors, 0 warnings 00:00:00.2759678
```
