---
name: python-coding-standards
description: Enforce Python coding standards including PEP 8 compliance, consistent docstring formatting (Google style), type hints, and professional code organization. Use whenever writing, reviewing, or refactoring Python code to ensure production-ready quality and maintainability.
---

# Python Coding Standards

This skill ensures Python code adheres to professional standards. Apply these standards to all Python code you write or review, on top of the language-agnostic `general-coding-standards.md`.

## Style Guide

Follow the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html) for most formatting.

## Code Linting

Use linting rules provided by Pylint and correct linting errors before considering the code complete.

```bash
python -m pylint <file_or_module>
```

## Running Python Commands

When using `uv` in the Codex sandbox, keep the cache inside the repository so commands do not require approval to access `~/.cache/uv`.

```bash
uv --cache-dir .uv-cache run pytest
uv --cache-dir .uv-cache run python -m pylint <file_or_module>
```

## Code Formatting

Follow PEP8 with these specific exceptions:

**Line length:** 120 characters (ignore PEP 8 and Black standards for line length)

## Dependency Management

Follow the general dependency principles in `general-coding-standards.md`. Python specifics:

- Prefer the standard library (`json`, `datetime`, `pathlib`, `collections`, `itertools`, `functools`) before reaching for a package.
- Pin exact versions in `requirements.txt` (`pandas==2.0.1`, not `pandas>=2.0`), and update it after any change:

```bash
pip freeze > requirements.txt
```

## Docstring Standards (Sphinx)

Use docstrings that follow the Sphinx formatting rules

## Logging

Use Python's `logging` module, not print statements. Configure at module level:

```python
import logging

logger = logging.getLogger(__name__)

def process_transactions(data: pd.DataFrame) -> pd.DataFrame:
    """Process transaction data and apply business rules."""
    logger.info("Processing %d transactions", len(data))

    try:
        result = apply_rules(data)
        logger.debug("Applied %d validation rules", len(rules))
        return result
    except ValidationError as e:
        logger.error("Validation failed: %s", e, exc_info=True)
        raise
```

**Use lazy % formatting in logging calls** (not f-strings) so string interpolation is skipped when the log level is disabled.

**Logging levels:**
- `DEBUG`: Detailed diagnostic info
- `INFO`: General informational messages
- `WARNING`: Unexpected but handled situations
- `ERROR`: Errors that need attention
- `CRITICAL`: System-level failures

## Standards Checklist

Before submitting code, verify:

- [ ] Imports organized
- [ ] Pylint passes (`python -m pylint <file>`) with no warnings or errors
- [ ] Google style guide followed
- [ ] PEP 8 compliance (line length, naming, whitespace)
- [ ] Docstrings and type hints present
- [ ] Logging instead of print statements with error messages including helpful context
- [ ] `requirements.txt` updated if dependencies changed
- [ ] All tests still pass (if refactoring)
