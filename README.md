# Uncrustify C++ Github Action
Runs an (uncrustify)[https://github.com/uncrustify/uncrustify] config against C++ implementation and header files in a given repo. 

The script looks for the following file endings:
* .cpp
* .cxx
* .h
* .hpp

Only runs on files that have been added or modified in a given commit.

## Example configuations

Basic: 
```yml
on: [ pull_request ]

jobs:
  cpp_style_check:
    runs-on: ubuntu-latest
    name: Check ++ Style
    steps:
    - name: Checkout this commit
      uses: actions/checkout@v2
    - name: Run style checks
      uses: coleaeason/actions-uncrustify@v1
```

Use a specific configuartion file via input: 
```yml
on: [ pull_request ]

jobs:
  cpp_style_check:
    runs-on: ubuntu-latest
    name: Check ++ Style
    steps:
    - name: Checkout this commit
      uses: actions/checkout@v2
    - name: Run style checks
      uses: coleaeason/actions-uncrustify@v1
      with: 
        configPath: 'myConfig.cfg'
```

Checks for usaged of `std::`: 
```yml
on: [ pull_request ]

jobs:
  cpp_style_check:
    runs-on: ubuntu-latest
    name: Check ++ Style
    steps:
    - name: Checkout this commit
      uses: actions/checkout@v2
    - name: Run style checks
      uses: coleaeason/actions-uncrustify@v1
      with: 
        checkSTD: 'true'
```