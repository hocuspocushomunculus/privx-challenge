*** Settings ***
Documentation   PrivX REST API testing robot tests
Library         RequestsLibrary
Library         resources/lib_privx.py      WITH NAME      privx
Variables       resources/variables.py

Test Setup      privx.Initialize Item Database

*** Test Cases ***
User is able to list all items
    [Documentation]  Make a GET request to /items/ endpoint
    ...  of the REST API server and validate the returned value.
    ${response}=     GET   ${REST_API_URL}items/
    Should Be Equal  ${response.status_code}    ${200}
    Should Be Equal  ${response.json()}         ${default_items}

User is able to filter items
    [Documentation]  Make a GET request to /items/?param=value
    ...  endpoint of the REST API server and validate the returned value.
    ...  Also test for filtering item with no matching key & value.
    # Filtering returns something
    ${response}=     GET   ${REST_API_URL}items/?name\=item_2
    Should Be Equal  ${response.status_code}    ${200}
    Should Be Equal  ${response.json()}[0]      ${ITEM_2}

    # Filtering doesn't return anything
    ${response}=     GET   ${REST_API_URL}items/?name\=no_such_name
    Should Be Equal  ${response.status_code}    ${200}
    Should Be Equal  ${response.json()}         ${EMPTY_LIST}

User is able to get item by name
    [Documentation]  Make a GET request to /items/<name>/ endpoint
    ...  of the REST API server and validate the returned value.
    ...  Also test for non-existent item.
    # Positive case
    ${response}=     GET   ${REST_API_URL}items/item_2
    Should Be Equal  ${response.status_code}    ${200}
    Should Be Equal  ${response.json()}         ${ITEM_2}

    # Negative case
    Run Keyword And Expect Error  HTTPError: 404 Client Error*
    ...  GET  ${REST_API_URL}items/non_existent_item

User is able to add new item
    [Documentation]  Make a POST request to /items/ endpoint
    ...  of the REST API server and validate the returned value.
    ...  Also test the negative cases:
    ...  - no "name" field provided in json data
    ...  - trying to add already existent item
    # Add a new item
    ${response}=     POST  ${REST_API_URL}items  json=${NEW_ITEM}
    Should Be Equal  ${response.status_code}     ${201}

    # Check if it has been added
    ${response}=     GET   ${REST_API_URL}items/?name\=${NEW_ITEM['name']}
    Should Be Equal  ${response.status_code}     ${200}
    Should Be Equal  ${response.json()}[0]       ${NEW_ITEM}

    # Try adding new item again
    Run Keyword And Expect Error  HTTPError: 400 Client Error*
    ...  POST  ${REST_API_URL}items/  json=${NEW_ITEM}

    # Try adding an item without "name"
    Run Keyword And Expect Error  HTTPError: 400 Client Error*
    ...  POST  ${REST_API_URL}items/  json=${NEW_ITEM_WITHOUT_NAME}

User is able to delete an item by name
    [Documentation]  Make a DELETE request to /items/<name>/
    ...  endpoint of the REST API server and validate the returned value.
    ...  Also test removal of non-existent item
    # Remove item_2
    ${response}=     DELETE   ${REST_API_URL}items/item_2
    Should Be Equal  ${response.status_code}     ${204}

    # Check if item_2 exists (should not)
    Run Keyword And Expect Error  HTTPError: 404 Client Error*
    ...  GET  ${REST_API_URL}items/item_2

    # Try removing item_2 again
    Run Keyword And Expect Error  HTTPError: 404 Client Error*
    ...  DELETE  ${REST_API_URL}items/item_2
