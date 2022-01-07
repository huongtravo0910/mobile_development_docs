# APPLICATION STATE

## WHAT ?

In iOS 4 and later:

- Foreground, background, suspend, terminate
- When the app occupies the screen, it is in the foreground
- When the other app occupies the screen,the app is backgrounded and suspended
- Suspension means that your app is essentially freeze-dried; its process still exists, but it isn’t actively running, and it isn’t getting any events
- An app in a suspended state is still in memory.
- The app was not terminated; it simply stopped and froze, and waited in suspended animation. Returning to your app no longer means that your app is launched, but merely that it is resumed.
- Over time, successive iOS systems have complicated the picture:
  - Some apps can be backgrounded without being suspended.
  - An app that has been suspended can be woken briefly, remaining in the background, in order to receive and respond to a message — in order to be told, for instance, that the user has crossed a geofence, or that a background download has completed.
  - There is also an intermediate state in which your app can find itself, where it is neither frontmost nor backgrounded. (For instance, when the user summons the control center or notification center in front of your app. In such situations, your app may be inactive without actually being backgrounded).
    (Book)

# BACKGROUND MODE

## What?

- A mode that allows app to keep running in the background in very specific cases.
- In iOS, only specific app types are allowed to run in the background:
  (https://stackoverflow.com/questions/15086619/confusion-between-background-vs-suspended-app-states)
  - Apps that play audible content to the user while in the background, such as a music player app
  - Apps that keep users informed of their location at all times, such as a navigation app
  - Apps that support Voice over Internet Protocol (VoIP)
  - Newsstand apps that need to download and process new content
  - Apps that receive regular updates from external accessories

## How?

- Go to General -> Signing & Capacities -> Add 'Background Modes' Capacity
- Click cases using background

# Background Task Completion

## PROBLEM

- A problem arises if the app is backgrounded and suspended while the code is running.
- as the app goes into the background, the system waits a very short time (less than 5 seconds) for your app to finish doing whatever it may be doing, and it then suspends your app.
- It could be a problem for lengthy background tasks, including asynchronous tasks performed by the frameworks


## WHAT TO DO?

- protect a lengthy background task against interruption
- requesting extra time for completion just in case the app is backgrounded

## HOW
(book)
- call UIApplication’s beginBackgroundTask(expirationHandler:) to announce that a lengthy task is beginning
- This tells the system that if your app is backgrounded, you’d like to be granted some extra time to complete this task.
- call UIApplication’s endBackground- Task(\_:), passing in the same identification number that you got from your call to beginBackgroundTask(expirationHandler:)
- This tells the system that your lengthy task is over and that there is no need to grant you any more background time.
  
- Cases: sending messages, saving files into disks, completing user-initiate request,...
- The OS will give extra time, about 30s.


# Background fetch

## What?

- Periodical tasks: social media feed, emails, latest stock price, etc ..

## How?

- Prior to iOS 13:

  - sample code:

  ```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

    return true
  }

  ```

  ```swift
   func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if let tabBarController = window?.rootViewController as? UITabBarController,
      let viewControllers = tabBarController.viewControllers
    {
      for viewController in viewControllers {
        if let fetchViewController = viewController as? FetchViewController {
          fetchViewController.fetch {
            fetchViewController.updateUI()
            completionHandler(.newData)
          }
        }
      }
    }
  }
  ```

- After iOS 13:
  - At WWDC 2019, Apple introduced a new framework for scheduling background work: BackgroundTasks.(2 tasks: BGAppRefreshTaskRequest, and BGProcessingTaskRequest )
  - `BGProcessingTask`: for long running and maintenance tasks such backup and cleanup
  - `BGAppRefreshTask` : to keep your app up-to-date throughout the day
  - `BGTaskScheduler` : monitors the system state such as battery level, background usage, and more, so it chooses the optimal time to run your tasks
  - First step: register the identifiers of background tasks executed in our app in Info.plist
  ```
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>YOUR_REFRESH_TASK_ID</string>
        <string>YOUR_PROCESSING_TASK_ID</string>
    </array>
  ```
  - Then: create BGAppRefreshTaskRequests and BGProcessingTaskRequests and submit them to BGTaskScheduler
  - When the scheduler wakes up the app to pass the tasks, will get their BGAppRefreshTask and BGProcessingTask counterparts.
  - BGTaskScheduler sees that the system meets all the conditions required for a specific task, it will wake up your app in the background, and it will handle it the task from the scheduler.
  - If we get a BGAppRefreshTask, we can fetch content, process it, and update our UI.
  - If we get a BGProcessingTask, we can do some cleanup, backups, or other similar tasks.
  - When the task is finished, we need to mark it as completed, so we can allow the app to suspend.

# Background Processing

## What?

- request that a task be performed only while the app is in the background
- before the iOS 13, if we want to run a code in the background, we only do it via background fetch in capabilities
- `Background Task Framework` has been come by iOS 13
- Background Processing is a new background mode (https://www.andyibanez.com/posts/modern-background-tasks-ios13/)
- This is what allows you to perform deferrable maintenance work, including machine learning tasks such as on-device Core ML training.

## How?

- BGProcessingTaskRequest
- BGTaskScheduler
- Like above

- In a WWDC 2020 video, Apple appears to be saying that if the user has switched off Background App Refresh (in Settings, under General), background process‐ ing tasks will not take place.
