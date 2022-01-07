# UI LAYER

## WHAT IS UI LAYER IN iOS?

- According to multiple layer architecture, UI layer is the top layer, sits on top od where user can see and interact with the app (UI layer - Business Logic Layer - Data Layer)
- Unit of UI layer is UI component / UI elements
- What UI Elements are? (https://www.tutorialspoint.com/ios/ios_ui_elements.htm)
  - UI elements are the visual elements that we can see in our applications.
    - Interactive elements : elements respond to user interactions - buttons, text fields,...
    - Informative elements: element shows information for user - images, labels,...
- How to Add UI Elements?
  - In code
  - Interface builder (storyboard, nib file - XML files) (https://blog.scottlogic.com/2019/12/11/Exploring-SwiftUI-1.html)
    - Xib files are used to design individual components that can be reused.
    - Storyboard files are used to define a sequence of screens as shown in the image, which the user can navigate between.
- Coding UI: (https://blog.scottlogic.com/2020/01/06/Exploring-SwiftUI-2-React-comparison.html)
  - Imperative approach (UIKit)
    - concerned with HOW
    - event-driven user interface
    - define exactly how to construct your UI in an initial state, and provide code that manipulates that UI over time in response to things such as user interaction.
    - in response to a user action, manipulate a view from the application
  - Declarative approach (SwiftUI)
    - concerned with WHAT
    - state-driven user interface
    - define the UI that should appear given a certain state of the application
    - events, such as user interaction, only affect this state; when the state changes, the framework will trigger an update to the UI.
    - state is declared using properties on the struct and can be labelled using a property wrappers.
    - > use @State if the View owns the underlying data
    - > use @Binding if a parent View owns it 

# UI SYSTEM DESIGN

## WHAT IS UI SYSTEM DESIGN?
(https://medium.muz.li/creating-a-ui-component-design-system-step-by-step-guide-5c18b5a2f529#:~:text=What%20is%20a%20UI%20Design,it%20as%20an%20Instruction%20manual)
- A UI design system is a set of standards for design and code along with components that unify both these practices helping them complement one another and producing the exact result which is conceptualized. Think of it as an Instruction manual. 
- It’s also like an inventory which can be used to pick up resources and use them in your design.
- UI SYSTEM DESIGN button : https://manabie.slack.com/archives/C01SYKX1BPE/p1635403380297100
## ORGANIZING AND MAINTAINING A UI LIBRARY
- Create reusable components
- Using story book
- Storybook is a development tool that allows developers to create organized UI systems making both the building process and documentation more efficient and easier to use.
- Storybook is originated from front-end (React), now there is also a storybook in Flutter
- Storybook in JS : https://storybook.js.org/ 
- Storybook in Flutter : https://pub.dev/packages/storybook_flutter 