#!/usr/bin/env python3
"""
Store variables for PrivX robot test.
"""
REST_API_URL = "http://rest_api_server:5000/"
DEFAULT_ITEMS = [
    {"name": "item_0"},
    {"name": "item_1"},
    {"name": "item_2"},
    {"name": "item_3"},
    {"name": "item_4"}
]
ITEM_2 = {"name": "item_2"}
EMPTY_LIST = []
ERROR_MESSAGE = {'error': 'message'}

NEW_ITEM = {"name": "new_item", "id": "foo", "price": "baz"}
NEW_ITEM_WITHOUT_NAME = {"not_a_name": "xyz"}
