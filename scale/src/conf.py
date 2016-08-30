# -*- coding: utf-8 -*-

import sys
import os

sys.path.append(os.path.dirname(__file__))

extensions = ['sphinx.ext.autodoc']

source_suffix = '.rst'

master_doc = 'modules'

project = u'lambda-scale'
copyright = u'2016, digit'
author = u'digit'

version = u'0.1.0'
release = u'0.1.0'
language = None
exclude_patterns = [
    'build', 'Thumbs.db',
    '.DS_Store', '.tox',
    'conf.py', 'setup.py'
]
pygments_style = 'sphinx'
todo_include_todos = False

html_theme = 'alabaster'
