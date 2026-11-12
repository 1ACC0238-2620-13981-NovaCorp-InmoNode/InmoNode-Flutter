@acceptance
@US-53
Feature: Lot publication to the catalog
  As a catalog back-office administrator
  I want to publish a registered lot
  So that it is available for separation across the ecosystem

  Background:
    Given the project "Los Pinos" was created with the stages "Norte, Sur"
    And its lot "N-01" was registered at 45000 with its polygon
    And a catalog administrator is signed in
    And the administrator opens the project "Los Pinos"

  Scenario: Successful publication
    When the administrator publishes the project
    And the administrator publishes the lot "N-01"
    Then the project "Los Pinos" lists the lot "N-01" in the stage "Norte" as "Disponible"
    And a buyer finds the lot "N-01" of "Los Pinos" available in the catalog

  Scenario Outline: Publication blocked by missing data
    When the administrator registers the lot "N-02" without its "<missing data>"
    Then the lot "N-02" is not registered, so it cannot be published
    And the field "<field>" is marked with "<message>"

    Examples:
      | missing data | field                                  | message                                                   |
      | price        | Precio (S/) *                          | Ingresa el precio en soles, por ejemplo 45000 o 45,000.50 |
      | polygon      | Polígono: longitud,latitud por línea * | Ingresa al menos 3 vértices, uno por línea                |
