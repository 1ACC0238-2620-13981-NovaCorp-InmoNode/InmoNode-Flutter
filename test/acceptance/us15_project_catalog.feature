@acceptance
@US-15
Feature: Real estate project catalog
  As a buyer and investor
  I want to see the list of available projects
  So that I can weigh purchase options by location and base prices

  Scenario: Overview of the active projects
    Given the published project "Los Pinos" in "Carabayllo, Lima" with these lots:
      | 'code' | 'price' | 'status'    |
      | 'N-01' | 45000   | 'AVAILABLE' |
      | 'N-02' | 52000   | 'AVAILABLE' |
      | 'S-01' | 58000   | 'AVAILABLE' |
      | 'S-02' | 49000   | 'SOLD'      |
    And the published project "Brisas del Sur" in "Lurín, Lima" with these lots:
      | 'code' | 'price' | 'status'    |
      | 'B-01' | 39500   | 'AVAILABLE' |
      | 'B-02' | 39500   | 'RESERVED'  |
    And a buyer is signed in
    When the buyer opens the project catalog
    Then the catalog lists the projects "Brisas del Sur, Los Pinos"
    And the project "Los Pinos" shows a thumbnail
    And the project "Los Pinos" shows the price range "S/ 45,000.00 – S/ 58,000.00"
    And the project "Los Pinos" shows the availability "3 de 4 lotes disponibles (75 %)"
    And the project "Brisas del Sur" shows the price range "S/ 39,500.00"
    And the project "Brisas del Sur" shows the availability "1 de 2 lotes disponibles (50 %)"

  Scenario: Sold-out project indicator
    Given the published project "Los Pinos" in "Carabayllo, Lima" with these lots:
      | 'code' | 'price' | 'status'    |
      | 'N-01' | 45000   | 'AVAILABLE' |
    And the published project "Las Dunas" in "Chilca, Lima" with these lots:
      | 'code' | 'price' | 'status' |
      | 'A-01' | 38000   | 'SOLD'   |
      | 'A-02' | 41000   | 'SOLD'   |
    And a buyer is signed in
    When the buyer opens the project catalog
    Then the catalog lists the projects "Las Dunas, Los Pinos"
    And the project "Las Dunas" is tagged "VENDIDO TOTALMENTE"
    And the project "Las Dunas" shows the availability "Sus 2 lotes están vendidos"
    And the project "Los Pinos" is not tagged "VENDIDO TOTALMENTE"
