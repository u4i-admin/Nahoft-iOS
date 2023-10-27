//
//  TimeChange.swift
//  Nahoft
//
//  Created by Sadra Sadri on 9.08.2023.
//

import Foundation
import BackgroundTasks

class TimeChangeService {
    static func handleAppRefresh(task: BGAppRefreshTask) {
       // Schedule a new refresh task.
       scheduleAppRefresh()

       // Create an operation that performs the main part of the background task.
//       let operation = RefreshAppContentsOperation()
       
       // Provide the background task with an expiration handler that cancels the operation.
//       task.expirationHandler = {
//          operation.cancel()
//       }

       // Inform the system that the background task is complete
       // when the operation completes.
//       operation.completionBlock = {
//          task.setTaskCompleted(success: !operation.isCancelled)
//       }


       // Start the operation.
//       operationQueue.addOperation(operation)
     }
    
    static func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: "org.nahoft.appLock")
       // Fetch no earlier than 15 minutes from now.
       request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
}
