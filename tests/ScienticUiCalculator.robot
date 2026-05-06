# ==============================================
# Developed by Harish Dayalan
# Mail address: harishdayalan.rvcep@gmail.com
# Phone No.: +91-8310092040
# ==============================================

*** Settings ***
Documentation     Unified UI Test Suite for Scientific Calculator
Library           SeleniumLibrary
Library           Collections
Library           String
Resource    ../resources/keywords.robot
Resource    ../resources/variables.robot
Resource    ../resources/locators.robot

Suite Setup       Run Keywords    Setup Validation Suite    AND    Init Failure Collector
Suite Teardown    Close Calculator
Test Setup        Clear Calculator
Test Teardown     Capture Failure Screenshot


*** Test Cases ***

# =========================
# BASIC OPERATIONS
# =========================

Addition Test
    [Tags]    BasicOperations    TC-001
    Validate Expression    7+3    10    TC-001

Subtraction Test
    [Tags]    BasicOperations    TC-002
    Validate Expression    7-3    4    TC-002

Multiplication Test
    [Tags]    BasicOperations    TC-003
    Validate Expression    3*6    18    TC-003

Division Test
    [Tags]    BasicOperations    TC-004
    Validate Expression    8/2    4    TC-004


# =========================
# UI VALIDATION
# =========================

Digit Buttons
    [Tags]    UIValidation    TC-005
    Validate Digit Button Mapping

Clear Button
    [Tags]    UIValidation    TC-006
    Click Button    7
    Click Button    8
    Click Button    9
    Click Button    C
    ${result}=    Get Result
    Validate Result    ${result}    0    TC-006    Clear Button

Equals Button
    [Tags]    UIValidation    TC-007
    Validate Expression    5+2    7    TC-007


# =========================
# SCIENTIFIC FUNCTIONS
# =========================

Square Root Function
    [Tags]    ScientificFunctions    TC-008
    Validate Scientific    √    16    4    TC-008

Log Function
    [Tags]    ScientificFunctions    TC-009
    Validate Scientific    log    100    2    TC-009

Sin Function
    [Tags]    ScientificFunctions    TC-010
    Validate Scientific    sin    0    0    TC-010

Cos Function
    [Tags]    ScientificFunctions    TC-011
    Validate Scientific    cos    0    1    TC-011

Tan Function
    [Tags]    ScientificFunctions    TC-012
    Validate Scientific    tan    0    0    TC-012


# =========================
# EDGE CASES
# =========================

Divide By Zero
    [Tags]    EdgeCases    TC-013
    ${result}=    Calculate Expression    7/0
    Run Keyword And Continue On Failure
    ...    Should Contain Any    ${result}    Error    Infinity

Invalid Input Handling
    [Tags]    EdgeCases    TC-014
    Input Expression    abc
    ${result}=    Get Result
    Run Keyword And Continue On Failure
    ...    Should Contain Any    ${result}    Error    Invalid

Decimal Precision
    [Tags]    EdgeCases    TC-015
    ${result}=    Calculate Expression    0.1+0.2
    Run Keyword And Continue On Failure
    ...    Should Be Equal As Numbers    ${result}    0.3    0.01


# =========================
# FINAL SUMMARY
# =========================

End Of Validation Summary
    Report Failures At End