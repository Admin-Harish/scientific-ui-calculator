*** Settings ***
Library    SeleniumLibrary
Library    String
Resource   variables.robot
Resource   locators.robot

*** Keywords ***

# ---------- Setup ----------
Setup Validation Suite
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage

    Open Browser    ${URL}    chrome    options=${options}
    Maximize Browser Window

Close Calculator
    Close Browser

Init Failure Collector
    ${failures}=    Create List
    Set Suite Variable    ${FAILURES}    ${failures}


# ---------- Core Actions ----------
Click Button
    [Arguments]    ${value}

    ${value}=    Run Keyword If    '${value}' == '*'    Set Variable    ×
    ...    ELSE IF    '${value}' == '/'    Set Variable    ÷
    ...    ELSE IF    '${value}' == '-'    Set Variable    −
    ...    ELSE    Set Variable    ${value}

    ${locator}=    Set Variable    xpath=//button[normalize-space(.)='${value}']
    Click Element    ${locator}

Clear Calculator
    Click Element    ${CLEAR_BTN}

Get Result
    ${status}    ${value}=    Run Keyword And Ignore Error    Get Value    ${DISPLAY}

    IF    '${status}' == 'PASS'
        ${result}=    Set Variable    ${value}
    ELSE
        ${result}=    Get Text    ${DISPLAY}
    END

    ${result}=    Strip String    ${result}
    RETURN    ${result}

Input Expression
    [Arguments]    ${expression}
    ${chars}=    Split String To Characters    ${expression}
    FOR    ${char}    IN    @{chars}
        Click Button    ${char}
    END

Calculate Expression
    [Arguments]    ${expression}
    Input Expression    ${expression}
    Click Button    =
    ${result}=    Get Result
    RETURN    ${result}


# ---------- Validations ----------
Validate Expression
    [Arguments]    ${expr}    ${expected}    ${tc}
    ${result}=    Calculate Expression    ${expr}
    Validate Result    ${result}    ${expected}    ${tc}    ${expr}

Validate Scientific
    [Arguments]    ${func}    ${input}    ${expected}    ${tc}

    Clear Calculator
    Input Expression    ${input}
    Click Button    ${func}
    Click Button    =
    ${result}=    Get Result
    Validate Result    ${result}    ${expected}    ${tc}    ${func}

Validate Result
    [Arguments]    ${actual}    ${expected}    ${tc}    ${context}

    ${status}=    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${actual}    ${expected}

    IF    not ${status}
        ${msg}=    Set Variable
        ...    ❌ ${tc} FAILED (${context}) → Expected: ${expected}, Got: ${actual}

        Log    ${msg}    ERROR
        Append To List    ${FAILURES}    ${msg}
    ELSE
        Log    ✅ ${tc} PASSED
    END


Validate Digit Button Mapping
    FOR    ${digit}    IN RANGE    0    10
        Clear Calculator
        Click Button    ${digit}
        ${result}=    Get Result
        ${digit_str}=    Convert To String    ${digit}

        ${status}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${result}    ${digit_str}

        IF    not ${status}
            ${msg}=    Set Variable
            ...    ❌ TC-005 Digit ${digit} failed → Got ${result}
            Log    ${msg}    ERROR
            Append To List    ${FAILURES}    ${msg}
        END
    END


# ---------- Reporting ----------
Capture Failure Screenshot
    ${timestamp}=    Get Time    epoch
    Capture Page Screenshot    reports/failure_${timestamp}.png

Report Failures At End
    Log    ===== FINAL SUMMARY =====
    ${count}=    Get Length    ${FAILURES}

    IF    ${count} > 0
        FOR    ${f}    IN    @{FAILURES}
            Log    ${f}    ERROR
        END
        Fail    ❌ Suite failed with ${count} issues
    ELSE
        Log    ✅ All tests passed
    END