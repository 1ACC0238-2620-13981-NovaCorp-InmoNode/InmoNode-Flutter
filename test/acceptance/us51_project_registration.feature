@acceptance
@US-51
Feature: Real estate project registration
  As a catalog back-office administrator
  I want to register a new real estate project with its name, location and stages
  So that its lots can be loaded afterwards

  Background:
    Given a catalog administrator is signed in

  Scenario: Project created successfully
    When the administrator creates the project "Los Pinos" in "Carabayllo, Lima" with the stages "Norte, Sur"
    Then the project "Los Pinos" is created as "Borrador"
    And the project "Los Pinos" has the stages "Norte, Sur"
    And the project "Los Pinos" is ready to receive lots

  Scenario: Registration rejected for missing data
    When the administrator creates the project "Los Pinos" without a location
    Then no project is created
    And the field "Ubicación *" is marked with "Completa este campo"
