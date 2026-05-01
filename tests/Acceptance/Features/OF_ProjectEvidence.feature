Feature: Final project evidence and records cleanup
  As a CMSC 471 project team member
  I want the project evidence, records workflow, and cleanup actions documented
  So that the final submission proves the system was built, tested, and reviewed

  Scenario: Verify Azure DevOps board is populated
    Given the CMSC 471 Azure DevOps project exists
    When the team views the board
    Then the board should show user stories, tasks, and bugs
    And at least five work items should be assigned to the student
    And completed work should be moved to Done

  Scenario: Verify GitHub commits are linked to DevOps tasks
    Given a DevOps task exists for a project change
    When the developer commits the change to GitHub
    Then the commit message should reference the Azure DevOps work item ID
    And the DevOps work item should show a link to the GitHub commit

  Scenario: Delete an inbox file without spaces
    Given an uploaded inbox file is named "food.png"
    When the user clicks the delete button for that file
    Then the frontend should call DELETE /api/inbox/{key}
    And the file should be removed from the S3 inbox bucket

  Scenario: Delete an inbox file with spaces
    Given an uploaded inbox file is named "list of food.png"
    When the user deletes the file
    Then the backend should decode the URL path key
    And the file should be removed from the S3 inbox bucket
    And GET /api/inbox should no longer return that file

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

  Scenario: Verify AWS cost estimate is documented
    Given the AWS Pricing Calculator estimate has been created
    When the README cost section is reviewed
    Then it should include the monthly cost
    And it should include the 12 month cost
    And it should list the AWS services included in the estimate

  Scenario: Verify template.yaml is commented
    Given the SAM template exists in the repository
    When the reviewer opens template.yaml
    Then major sections should include comments
    And the comments should explain API Gateway, S3, Lambda, Step Functions, DynamoDB, CloudWatch, and outputs
