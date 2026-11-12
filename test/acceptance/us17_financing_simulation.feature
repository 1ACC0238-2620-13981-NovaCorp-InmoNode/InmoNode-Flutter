@acceptance
@US-17
Feature: Self-service financing simulation
  As a buyer and investor
  I want to simulate payment schedules on the web
  So that I can weigh the financial viability of my investment without contacting an agent

  Background:
    Given the published project "Los Pinos" asks for a minimum down payment of 10 %, charges an annual rate of 12.5 % and finances up to 60 months
    And its lot "N-01" is available at 45000
    And a buyer is signed in
    And the buyer chooses the lot "N-01" of "Los Pinos" to simulate

  Scenario: Calculation with the standard rate
    When the buyer enters a down payment of "4500" and a term of 60 months
    And the buyer runs the simulation
    Then the monthly installment is "S/ 897.55"
    And the term is summarized as "60 cuotas, la última de S/ 897.84 por redondeo"
    And the breakdown shows:
      | 'concept'               | 'value'        |
      | 'Precio del lote'       | 'S/ 45,000.00' |
      | 'Cuota inicial (10 %)'  | 'S/ 4,500.00'  |
      | 'Monto financiado'      | 'S/ 40,500.00' |
      | 'Tasa de interés anual' | '12.5 %'       |
      | 'Intereses'             | 'S/ 13,353.29' |
      | 'Total a pagar'         | 'S/ 58,353.29' |
    And the schedule lists 60 monthly installments

  Scenario: Minimum down payment validation
    When the buyer enters a down payment of "4000" and a term of 60 months
    And the buyer runs the simulation
    Then the down payment is rejected with "La cuota inicial mínima es S/ 4,500.00 (10 % del precio)."
    And no quotation is requested
