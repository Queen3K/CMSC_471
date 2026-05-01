Feature: Yellow Sign Diner image processing workflow
  As a user of the Yellow Sign Diner dashboard
  I want to upload, process, and view text from images
  So that shopping list images can be converted into saved records

Scenario: Load the Yellow Sign Diner dashboard
  Given the AWS stack is deployed
  When the user opens the API Gateway root URL
  Then the Yellow Sign Diner dashboard should load
  And the page should show the Inbox, Process, and Records panels

Scenario: Upload an image to the inbox
  Given the Yellow Sign Diner dashboard is open
  When the user uploads a PNG or JPG image
  Then the frontend should request a presigned S3 upload URL
  And the image should be uploaded to the inbox S3 bucket
  And the image should appear in the Inbox panel

Scenario: Select an uploaded image
  Given uploaded files are displayed in the Inbox panel
  When the user clicks an inbox file
  Then the selected filename should be saved
  And the selected row should be highlighted
  And the Process panel should show the current selection

Scenario: Start an image processing job
  Given an uploaded image is selected
  When the user clicks the Process button
  Then the frontend should call POST /api/jobs
  And LSubmit should create a jobId
  And LSubmit should save the job as RUNNING in JobsTable
  And LSubmit should start the Step Functions state machine

Scenario: Run the Step Functions processing workflow
  Given a processing job has started
  When the Step Functions workflow runs
  Then the workflow should invoke L1Fetch
  And the workflow should invoke L2Call
  And the workflow should invoke L3Save

Scenario: Detect text with Amazon Textract
  Given L1Fetch returned the selected S3 image information
  When L2Call sends the image to Amazon Textract
  Then Textract should detect text from the uploaded image
  And the job log should report how many items were detected

Scenario: Save extracted records
  Given Textract returned detected text items
  When L3Save runs
  Then each detected item should be saved in RecordsTable
  And the job status should be updated to SUCCEEDED in JobsTable

Scenario: Reload records after processing
  Given the job reaches SUCCEEDED
  When the frontend stops polling the job
  Then the frontend should call loadRecords
  And the Records panel should display saved records from RecordsTable