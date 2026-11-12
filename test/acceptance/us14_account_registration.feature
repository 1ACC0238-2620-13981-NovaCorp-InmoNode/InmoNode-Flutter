@acceptance
@US-14
Feature: Web account registration
  As a buyer and investor
  I want to create an account on the web platform
  So that I can explore projects, simulate prices and manage my real estate purchases

  Scenario: Account creation and validation
    Given the visitor opens InmoNode without a session
    When the visitor signs up as "ana@mail.com" with a valid password
    Then the account "ana@mail.com" is created as inactive
    And a single-use verification link is emailed to "ana@mail.com"
    And the visitor is asked to open the link sent to "ana@mail.com"

  Scenario: Email already registered
    Given an account already exists for "luis@mail.com"
    And the visitor opens InmoNode without a session
    When the visitor signs up as "luis@mail.com" with a valid password
    Then the sign-up is rejected with "El correo ya está registrado; usa la recuperación de contraseña"
    And no new account is created for "luis@mail.com"
    And the visitor is offered the password recovery flow
