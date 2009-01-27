Feature: Sign in
  In order to get access to protected sections of the site
  A registered user
  Should be able to sign in
  
   Scenario User is not registered
      Given there is no user with "email@person.com"
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should see "Bad email or password"
      And I should not be signed in      
  
    Scenario: User is not confirmed
      Given I signed up with "email@person.com/password"
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should see "User has not confirmed email"
      And I should not be signed in
      
   Scenario: User enters wrong password
      Given I am signed up and confirmed as "email@person.com/password"
      When I go to the sign in page
      And I sign in as "email@person.com/wrongpassword"
      Then I should see "Bad email or password"
      And I should not be signed in
      
   Scenario: User signs in successfully
      Given I am signed up and confirmed as "email@person.com/password"
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should see "Signed in successfully"
      And I should be signed in
      
   Scenario: User signs in and checks "remember me"
      Given I am signed up and confirmed as "email@person.com/password"
      When I go to the sign in page
      And I sign in with "remember me" as "email@person.com/password"
      Then I should see "Signed in successfully"
      And I should be signed in    
      When I return next time
      Then I should be signed in
