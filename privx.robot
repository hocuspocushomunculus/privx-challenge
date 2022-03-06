*** Settings ***
Documentation   PrivX REST API testing robot tests
Library         RequestsLibrary
Variables       resources/variables.py

*** Test Cases ***
User is able to list all items
    [Documentation]  Make a GET request to /items/(?param=value) endpoint
    ...  of the REST API server and check the returned value.
    ${response}=    GET  http://rest_api_server:5000/items/
    Log  ${response}

# User is able to filter items

# User is able to get item by name

# User is able to add new item

# User is able to delete an item by name
