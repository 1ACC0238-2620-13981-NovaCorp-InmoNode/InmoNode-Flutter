@acceptance
@US-52
Feature: Lot registration with its technical sheet and cadastral polygon
  As a catalog back-office administrator
  I want to register a lot in a project with its dimensions, base price and cadastral polygon
  So that its complete technical sheet is ready before it is published

  Background:
    Given the project "Los Pinos" was created with the stages "Norte, Sur"
    And a catalog administrator is signed in
    And the administrator opens the project "Los Pinos"

  Scenario: Lot registered in an existing project
    When the administrator registers this lot:
      | 'code' | 'stage' | 'area' | 'front' | 'depth' | 'price' | 'polygon'                                                                   |
      | 'N-01' | 'Sur'   | 120    | 8       | 15      | 45000   | '-77.0428,-12.0464; -77.0427,-12.0464; -77.0427,-12.0465; -77.0428,-12.0465' |
    Then the project "Los Pinos" lists the lot "N-01" in the stage "Sur" as "Borrador"
    And the lot "N-01" is saved with an area of 120 and a price of 45000
    And buyers cannot see the lot "N-01"

  Scenario Outline: Invalid polygon rejected
    When the administrator registers the lot "N-02" with the polygon "<polygon>"
    Then the lot "N-02" is not saved
    And the administrator is asked to fix the polygon with "<message>"

    Examples:
      | polygon                                                                     | message                                                                                |
      | -77.0428,-12.0464; -77.0427,-12.0465; -77.0427,-12.0464; -77.0428,-12.0465 | El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices. |
      | -77.0428,-12.0464; -77.0427,-12.0464                                        | Ingresa al menos 3 vértices, uno por línea                                             |
