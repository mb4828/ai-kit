---
name: python-coding-standards
description: Enforce Python coding standards including PEP 8 compliance, consistent docstring formatting (Google style), type hints, and professional code organization. Use whenever writing, reviewing, or refactoring Python code to ensure production-ready quality and maintainability.
---

# Python Coding Standards

This skill ensures Python code adheres to professional standards. Apply these standards to all Python code you write or review.

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

## Code Organization

**Function length:** Keep functions under 30 lines or cyclomatic complexity of 20 (if available). If longer, break into smaller helper functions.

**Single Responsibility Principle:** Each function/class should have one clear purpose.

**Avoid globals:** Use function parameters and return values. Constants at module level (top of file) and package level (constants.py) are acceptable. Don't use __init__.py for globals.

## Dependency Management

When adding new dependencies, follow this priority order:

1. **Python built-in libraries first** - Use standard library modules whenever possible (e.g., `json`, `datetime`, `pathlib`, `collections`, `itertools`, `functools`)
2. **Open source libraries second** - For functionality not in stdlib, prefer well-maintained open source packages
3. **Closed source libraries require permission** - Before adding any proprietary or closed source dependency, explicitly ask the user for approval

**Always update `requirements.txt` after adding or updating any dependency:**

```bash
# After installing a new package
pip freeze > requirements.txt
```

**Dependency best practices:**
- Pin exact versions in `requirements.txt` for reproducibility (e.g., `pandas==2.0.1` not `pandas>=2.0`)
- Document why non-obvious dependencies are needed (inline comment in requirements.txt)
- Avoid adding dependencies for trivial functionality you could implement in 10-20 lines
- Check package maintenance status (recent commits, active issues, security track record)
- Prefer packages with minimal transitive dependencies

## Docstring Standards (Sphinx)

Use docstrings that follow the Sphinx formatting rules

## Comments

Comments should explain *why*, not *what*. The code should be self-explanatory for *what* it does but in the case that it is non-obvious at first glance (to a competent human developer), a comment should be employed.

**Code block comments:** Use code block comments before tricky blocks of code where the context of the block is not immediately obvious.

**Good:**
```python
# Use exponential weighting to give more importance to recent observations
weights = np.exp(-decay_rate * np.arange(n_periods))
```

**Bad:**
```python
# Calculate weights
weights = np.exp(-decay_rate * np.arange(n_periods))
```

**Inline comments:** Use inline comments sparingly and only in the case where the context for the line of code is not immediately obvious:**

**Good:**
```python
x = x + 1  # Compensate for border
```

**Bad:**
```python
x = x + 1  # Increment x
```

**TODO comments:** Include ticket number or date:
```python
# TODO(PROJ-123): Replace with async implementation when API supports it
# TODO(2026-02-15): Remove backward compatibility after migration
```

**Section dividers** It's acceptable to divide sections of code with comments. Use the formatting below. Do not overuse dividers - use only when each section contains more than 10 lines of code.
```python
# some code here

# ==== section divider ==== #

# some more code here
```

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

## Testing Hooks

Write code with testability in mind:

**Dependency injection:**
```python
def calculate_metrics(
    data: pd.DataFrame,
    calculator: Optional[Calculator] = None
) -> Dict[str, float]:
    """Calculate performance metrics.

    :param data: Historical price data.
    :param calculator: Optional calculator instance for testing.
    :return: Dict of metric names to values.
    """
    if calculator is None:
        calculator = DefaultCalculator()

    return calculator.compute(data)
```

**Avoid hardcoded values:** Use configuration or parameters instead.

**Pure functions:** Prefer functions without side effects when possible.

## Standards Checklist

Before submitting code, verify:

- [ ] Imports organized
- [ ] Pylint passes (`python -m pylint <file>`) with no warnings or errors
- [ ] Google style guide followed
- [ ] PEP 8 compliance (line length, naming, whitespace)
- [ ] Docstrings, type hints, and appropriate comments present
- [ ] Code is well organized
- [ ] Logging instead of print statements with error messages including helpful context
- [ ] `requirements.txt` updated if dependencies changed
- [ ] All tests still pass (if refactoring)
