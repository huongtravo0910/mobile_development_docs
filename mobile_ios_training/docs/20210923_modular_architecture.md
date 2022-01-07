# MODULAR ARCHITECTURE
## WHAT
(https://en.wikipedia.org/wiki/Modular_programming)
- Modular design in software engineering works through a modular programming technique (https://www.jigsawacademy.com/blogs/product-management/modular-design/)
- A software design technique that emphasizes separating the functionality of a program into independent, interchangeable modules, such that each contains everything necessary to execute only one aspect of the desired functionality.
- facilitates the "breaking down" of projects into several smaller projects.
(facilitate construction of large software programs and systems by decomposition into smaller pieces.)
- TERMINOLOGY: the term `assembly` (as in .NET languages like C#, F# or Visual Basic .NET) or `package` (as in Dart, Go or Java) is sometimes used instead of module.

## WHY
(https://www.tiny.cloud/blog/modular-programming-principle/)
- Code is easier to read
  * because it separates it into functions that each only deal with one aspect of the overall functionality. 
  * it can make files a lot smaller and easier to understand compared to monolithic code.
  * less code
  * understand the context of the code by its file name
- Easily find things later
  * if we can guess where a file might be and what the file or function might be called, it’s a lot easier to look for and find code
  * base on the context, we can guess the where is the code we need
- Reusability without bloat
  * no need to copy code
- Easier to test
- Easier to scale
- Easier refactoring, lower risk updates  
- Easier to collaborate
  * a modularized software project will be more easily assembled by large teams, since no team members are creating the whole system, or even need to know about the system as a whole. They can focus just on the assigned smaller task.
  * reduce git conflicts

## HOW
- Each module has a clear business context, clear purpose
- Each is separate, strong, and testable 
- A module’s responsibility should be narrow and focused, and no two modules’ purpose should overlap.
( single responsibility principle)
- Can be stacked together at the end to create your application. 
- Encapsulation: A module’s implementation is private.