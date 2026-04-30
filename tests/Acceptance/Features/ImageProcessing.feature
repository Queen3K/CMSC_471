Feature: Yellow Sign Diner serverless image processing system
  As a user of the Yellow Sign Diner dashboard
  I want to upload, manage, process, and save image text records
  So that shopping list images can be converted into stored records through AWS serverless services

  Scenario: Deploy the SAM infrastructure
    Given the SAM template defines the project infrastructure
    When the developer runs sam validate and sam build
    Then the template should validate successfully
    And the project should build without errors

  Scenario: Serve the frontend landing page
    Given the frontend index.html is uploaded to the website S3 bucket
    When the user opens the API Gateway root URL
    Then the Yellow Sign Diner dashboard should load
    And the page should show Inbox, Process, and Records panels

  Scenario: Check the health endpoint
    Given the API Gateway is deployed
    When the frontend calls GET /api/health
    Then the HealthFunction should return OK
    And the frontend should show the system integration status

  Scenario: Load inbox files
    Given uploaded image files exist in the inbox S3 bucket
    When the frontend calls GET /api/inbox
    Then the Inbox panel should display the uploaded files

  Scenario: Upload an image to the inbox
    Given the Yellow Sign Diner web application is open
    When the user uploads a PNG or JPG image
    Then the frontend should request a presigned S3 upload URL
    And the image should be uploaded to the inbox S3 bucket
    And the image should appear in the Inbox panel

  Scenario: Select an inbox file
    Given files are displayed in the Inbox panel
    When the user clicks an inbox file
    Then the selected filename should be saved in frontend state
    And the selected row should be visually highlighted
    And the Process panel should show the current selection

  Scenario: Delete an inbox file without spaces
    Given an uploaded inbox file is named "food.png"
    When the user clicks the delete button for that file
    Then the frontend should call DELETE /api/inbox/{key}
    And the file should be removed from the inbox S3 bucket
    And the Inbox panel should reload without that file

  Scenario: Delete an inbox file with spaces
    Given an uploaded inbox file is named "list of food.png"
    When the user clicks the delete button for that file
    Then the backend should decode the URL path key
    And the file should be removed from the inbox S3 bucket
    And GET /api/inbox should no longer return that file

  Scenario: Start an image processing job
    Given an uploaded image exists in the Inbox panel
    When the user selects the image
    And clicks the Process button
    Then the frontend should call POST /api/jobs
    And LSubmit should create a jobId
    And LSubmit should save the job as RUNNING in JobsTable
    And LSubmit should start the Step Functions state machine

  Scenario: Poll job status
    Given a processing job has started
    When the frontend calls GET /api/jobs/{jobId}
    Then LPoll should return the current job status from JobsTable
    And the frontend should write the job message to the log panel

  Scenario: Run the Step Functions workflow
    Given LSubmit has started the state machine
    When the workflow runs
    Then the state machine should invoke L1Fetch
    And the state machine should invoke L2Call
    And the state machine should invoke L3Save

  Scenario: Fetch image information
    Given a processing job contains a selected filename
    When L1Fetch runs
    Then it should return the jobId, filename, and inbox bucket name
    And the next workflow step should receive that image information

  Scenario: Detect text with Amazon Textract
    Given L1Fetch returned the image bucket and filename
    When L2Call invokes Amazon Textract
    Then Textract should detect text from the uploaded image
    And L2Call should return the detected text items
    And the job log should report how many items were detected

  Scenario: Save extracted records
    Given Textract returned detected text items
    When L3Save runs
    Then each detected item should be saved in RecordsTable
    And the job status should be updated to SUCCEEDED in JobsTable
    And the job message should show how many items were saved

  Scenario: Reload records after processing
    Given a job reaches SUCCEEDED or FAILED
    When the frontend clears the polling interval
    Then the frontend should call loadRecords
    And the Records panel should reload from GET /api/records

  Scenario: Load saved records
    Given extracted records exist in RecordsTable
    When the frontend calls GET /api/records
    Then LRecords should scan RecordsTable
    And the Records panel should display the saved records

  Scenario: Delete a saved record
    Given a saved record exists in the Records panel
    When the user deletes the record
    Then the frontend should call DELETE /api/records/{id}
    And LRecords should delete the item from RecordsTable
    And the Records panel should reload without the deleted record

  Scenario: Avoid duplicate manual records
    Given a processing job has completed successfully
    When the frontend reloads records from GET /api/records
    Then the Records panel should display only records from RecordsTable
    And it should not add an extra manual row for the processed filename

  Scenario: Track work through Azure DevOps and GitHub
    Given a user story or task exists in Azure DevOps
    When the developer commits the related project change to GitHub
    Then the commit message should reference the Azure DevOps work item
    And the board should show traceability between the task and the commit

  Scenario: Estimate yearly AWS cost
    Given the project uses S3, API Gateway, Lambda, Step Functions, DynamoDB, Textract, and CloudWatch
    When the developer creates an AWS Pricing Calculator estimate
    Then the estimate should include a monthly cost
    And the estimate should include a 12 month cost for the project