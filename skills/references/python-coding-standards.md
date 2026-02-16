---
name: python-coding-standards
description: Enforce Python coding standards including PEP 8 compliance, consistent docstring formatting (Google style), type hints, and professional code organization. Use whenever writing, reviewing, or refactoring Python code to ensure production-ready quality and maintainability.
---

# Python Coding Standards

This skill ensures Python code adheres to professional standards. Apply these standards to all Python code you write or review.

## Import Organization

Organize imports in this specific order, with a blank line between each group:

1. Standard library imports
2. Third-party imports
3. Local application imports

Within each group, sort alphabetically. Use absolute imports over relative imports.

```python
# Standard library
import os
import sys
from typing import Dict, List, Optional

# Third-party
import numpy as np
import pandas as pd

# Local
from myapp.models import User
from myapp.utils import validation
```

## Dependency Management

When adding new dependencies, follow this priority order:

1. **Python built-in libraries first** - Use standard library modules whenever possible (e.g., `json`, `datetime`, `pathlib`, `collections`, `itertools`, `functools`)
2. **Open source libraries second** - For functionality not in stdlib, prefer well-maintained open source packages
3. **Closed source libraries require permission** - Before adding any proprietary or closed source dependency, explicitly ask the user for approval

**Always update `requirements.txt` after adding or updating any dependency:**

```bash
# After installing a new package
pip freeze > requirements.txt

# Or manually add with version pinning
echo "pandas==2.0.1" >> requirements.txt
```

**Dependency best practices:**
- Pin exact versions in `requirements.txt` for reproducibility (e.g., `pandas==2.0.1` not `pandas>=2.0`)
- Document why non-obvious dependencies are needed (inline comment in requirements.txt)
- Avoid adding dependencies for trivial functionality you could implement in 10-20 lines
- Check package maintenance status (recent commits, active issues, security track record)
- Prefer packages with minimal transitive dependencies

Example `requirements.txt` with comments:
```
# Data processing
pandas==2.0.1
numpy==1.24.3

# API client
requests==2.31.0

# Testing
pytest==7.4.0
pytest-cov==4.1.0

# Database - required for legacy Oracle integration
cx_Oracle==8.3.0
```

## Type Hints

All function signatures must include type hints for parameters and return values. Use modern syntax (Python 3.9+) where applicable.

**Required:**
- All function parameters
- All function return types
- Class attributes when not obvious from initialization
- Complex data structures (use `typing` module)

```python
def calculate_returns(
    prices: pd.Series,
    periods: int = 252,
    method: str = "simple"
) -> pd.Series:
    """Calculate investment returns."""
    pass
```

For complex types, import from `typing`:
```python
from typing import Dict, List, Optional, Union, Callable, TypeVar
```

## Docstring Standards (Google Style)

Use Google-style docstrings for all public modules, classes, and functions. Private methods (starting with `_`) may omit docstrings if their purpose is obvious.

**Module docstring** (at top of file):
```python
"""Portfolio optimization and risk analysis tools.

This module provides functions for mean-variance optimization, risk parity
allocation, and performance attribution for equity portfolios.
"""
```

**Function/method docstrings:**
```python
def optimize_portfolio(
    returns: pd.DataFrame,
    target_return: float,
    constraints: Optional[Dict[str, float]] = None
) -> pd.Series:
    """Optimize portfolio weights using mean-variance optimization.
    
    Finds the minimum variance portfolio that achieves the target return
    while respecting position limits and sector constraints.
    
    Args:
        returns: Historical returns dataframe with assets as columns.
        target_return: Annualized target return (e.g., 0.08 for 8%).
        constraints: Optional dict of constraint names to values.
            Supported keys: 'max_position', 'min_position', 'sector_limits'.
    
    Returns:
        Series of optimal weights indexed by asset symbols, summing to 1.0.
    
    Raises:
        ValueError: If target_return is outside the feasible range.
        OptimizationError: If the solver fails to converge.
    
    Example:
        >>> returns = pd.DataFrame(...)
        >>> weights = optimize_portfolio(returns, target_return=0.08)
        >>> print(weights.sum())
        1.0
    """
    pass
```

**Class docstrings:**
```python
class RiskModel:
    """Factor-based equity risk model for portfolio analysis.
    
    This class implements a multi-factor risk model using PCA on historical
    returns to identify systematic risk factors and estimate covariance matrices.
    
    Attributes:
        n_factors: Number of principal components to retain.
        lookback_days: Historical window for factor estimation.
        factor_returns: DataFrame of estimated factor returns.
        factor_loadings: DataFrame of asset loadings on each factor.
    """
    
    def __init__(self, n_factors: int = 10, lookback_days: int = 252):
        """Initialize the risk model.
        
        Args:
            n_factors: Number of principal components to extract.
            lookback_days: Number of trading days for historical window.
        """
        pass
```

**Key docstring rules:**
- First line is a brief summary (one line, imperative mood)
- Blank line before detailed description
- Args/Returns/Raises sections clearly separated
- Parameter descriptions start with capital letter, no period at end unless multiple sentences
- Include examples for complex functions
- Document side effects explicitly

## Code Formatting

Follow PEP 8 with these specific rules:

**Line length:** 120 characters (ignore PEP 8 and Black standards for line length)

**Naming conventions:**
- `snake_case` for functions, variables, module names
- `PascalCase` for classes
- `UPPER_CASE` for constants
- `_leading_underscore` for private methods/attributes
- `__double_leading` for name mangling (rare, use sparingly)

**Whitespace:**
- 2 blank lines between top-level functions and classes
- 1 blank line between methods in a class
- No trailing whitespace
- Spaces around operators: `x = y + 1`, not `x=y+1`
- No spaces inside brackets: `func(x, y)`, not `func( x, y )`

**String quotes:** Use double quotes `"` for strings, single quotes `'` for dict keys or very short strings. Be consistent within a file.

## Error Handling

Use specific exception types rather than bare `except:`. Create custom exceptions for domain-specific errors.

```python
class PortfolioValidationError(ValueError):
    """Raised when portfolio weights fail validation."""
    pass

def validate_weights(weights: pd.Series) -> None:
    """Validate that portfolio weights sum to 1.0.
    
    Args:
        weights: Portfolio weights indexed by asset symbols.
    
    Raises:
        PortfolioValidationError: If weights don't sum to 1.0 within tolerance.
    """
    if not np.isclose(weights.sum(), 1.0, atol=1e-6):
        raise PortfolioValidationError(
            f"Weights sum to {weights.sum():.6f}, expected 1.0"
        )
```

**Error handling principles:**
- Catch specific exceptions, not broad `Exception`
- Include helpful error messages with context
- Use try-except-else-finally appropriately
- Don't silence exceptions without logging
- Re-raise with context when needed: `raise ValueError(...) from e`

## Code Organization

**Function length:** Keep functions under 30 lines or cyclomatic complexity of 20 (if available). If longer, break into smaller helper functions.

**Single Responsibility Principle:** Each function/class should have one clear purpose.

**Avoid globals:** Use function parameters and return values. Constants at module level are acceptable.

**Default arguments:** Never use mutable defaults. Use `None` and initialize inside function:
```python
def process_data(data: List[str], options: Optional[Dict] = None) -> List[str]:
    """Process data with optional configuration."""
    if options is None:
        options = {}
    # ...
```

**Constants:** Define module-level constants at the top after imports:
```python
DEFAULT_WINDOW = 252
MIN_OBSERVATIONS = 30
TRADING_DAYS_PER_YEAR = 252
```

## Comments

Comments should explain *why*, not *what*. The code should be self-explanatory for *what* it does.

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

**Inline comments:** Use sparingly. Prefer clear variable names over comments.

**TODO comments:** Include ticket number or date:
```python
# TODO(PROJ-123): Replace with async implementation when API supports it
# TODO(2026-02-15): Remove backward compatibility after migration
```

**Section dividers** It's acceptable to divide sections of code with comments but keep the formatting consistent. Do not overuse dividers - use only when each section contains more than 10 lines of code.
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
    logger.info(f"Processing {len(data)} transactions")
    
    try:
        result = apply_rules(data)
        logger.debug(f"Applied {len(rules)} validation rules")
        return result
    except ValidationError as e:
        logger.error(f"Validation failed: {e}", exc_info=True)
        raise
```

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
    
    Args:
        data: Historical price data.
        calculator: Optional calculator instance for testing.
    
    Returns:
        Dict of metric names to values.
    """
    if calculator is None:
        calculator = DefaultCalculator()
    
    return calculator.compute(data)
```

**Avoid hardcoded values:** Use configuration or parameters instead.

**Pure functions:** Prefer functions without side effects when possible.

## File Structure Template

Here's a complete template showing all standards:

```python
"""Portfolio risk analytics and optimization module.

This module provides tools for calculating portfolio risk metrics including
Value at Risk (VaR), Expected Shortfall (ES), and tracking error. It supports
both historical and parametric approaches.
"""

import logging
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
from scipy import stats

from myapp.models import Portfolio
from myapp.utils import validation

logger = logging.getLogger(__name__)

# Module-level constants
DEFAULT_CONFIDENCE = 0.95
TRADING_DAYS_PER_YEAR = 252
MIN_OBSERVATIONS = 30


class InsufficientDataError(ValueError):
    """Raised when insufficient historical data is available for calculation."""
    pass


def calculate_var(
    returns: pd.Series,
    confidence: float = DEFAULT_CONFIDENCE,
    method: str = "historical"
) -> float:
    """Calculate Value at Risk for a return series.
    
    Computes the maximum expected loss over a given time horizon at a
    specified confidence level using either historical or parametric methods.
    
    Args:
        returns: Historical returns series (daily, decimal format).
        confidence: Confidence level for VaR (e.g., 0.95 for 95%).
        method: Calculation method, either 'historical' or 'parametric'.
    
    Returns:
        Value at Risk as a positive number (e.g., 0.05 means 5% loss).
    
    Raises:
        InsufficientDataError: If fewer than MIN_OBSERVATIONS data points.
        ValueError: If method is not recognized or confidence is invalid.
    
    Example:
        >>> returns = pd.Series([0.01, -0.02, 0.015, -0.01])
        >>> var_95 = calculate_var(returns, confidence=0.95)
        >>> print(f"95% VaR: {var_95:.2%}")
        95% VaR: 1.90%
    """
    if len(returns) < MIN_OBSERVATIONS:
        raise InsufficientDataError(
            f"Need at least {MIN_OBSERVATIONS} observations, got {len(returns)}"
        )
    
    if not 0 < confidence < 1:
        raise ValueError(f"Confidence must be between 0 and 1, got {confidence}")
    
    logger.debug(f"Calculating VaR with {method} method at {confidence:.1%} confidence")
    
    if method == "historical":
        var = _historical_var(returns, confidence)
    elif method == "parametric":
        var = _parametric_var(returns, confidence)
    else:
        raise ValueError(f"Unknown method: {method}")
    
    logger.info(f"Calculated VaR: {var:.4f}")
    return var


def _historical_var(returns: pd.Series, confidence: float) -> float:
    """Calculate VaR using historical simulation method.
    
    Args:
        returns: Historical returns series.
        confidence: Confidence level.
    
    Returns:
        Historical VaR estimate.
    """
    # Take absolute value because we report losses as positive numbers
    return abs(returns.quantile(1 - confidence))


def _parametric_var(returns: pd.Series, confidence: float) -> float:
    """Calculate VaR using parametric (normal distribution) method.
    
    Args:
        returns: Historical returns series.
        confidence: Confidence level.
    
    Returns:
        Parametric VaR estimate.
    """
    mean = returns.mean()
    std = returns.std()
    z_score = stats.norm.ppf(1 - confidence)
    
    # VaR formula: -mean + z * sigma
    return abs(mean + z_score * std)


class RiskMetrics:
    """Container for portfolio risk metrics.
    
    Attributes:
        var_95: 95% Value at Risk.
        var_99: 99% Value at Risk.
        expected_shortfall: Expected Shortfall (CVaR) at 95%.
        tracking_error: Annualized tracking error vs benchmark.
    """
    
    def __init__(
        self,
        var_95: float,
        var_99: float,
        expected_shortfall: float,
        tracking_error: Optional[float] = None
    ):
        """Initialize risk metrics container.
        
        Args:
            var_95: 95% Value at Risk.
            var_99: 99% Value at Risk.
            expected_shortfall: Expected Shortfall at 95%.
            tracking_error: Optional tracking error vs benchmark.
        """
        self.var_95 = var_95
        self.var_99 = var_99
        self.expected_shortfall = expected_shortfall
        self.tracking_error = tracking_error
    
    def to_dict(self) -> Dict[str, float]:
        """Convert metrics to dictionary format.
        
        Returns:
            Dictionary mapping metric names to values.
        """
        metrics = {
            "var_95": self.var_95,
            "var_99": self.var_99,
            "expected_shortfall": self.expected_shortfall,
        }
        
        if self.tracking_error is not None:
            metrics["tracking_error"] = self.tracking_error
        
        return metrics
```

## Standards Checklist

Before submitting code, verify:

- [ ] Module docstring present at top of file
- [ ] Imports organized: stdlib, third-party, local
- [ ] All functions have type hints
- [ ] All public functions have Google-style docstrings
- [ ] PEP 8 compliance (line length, naming, whitespace)
- [ ] No bare `except:` clauses
- [ ] No mutable default arguments
- [ ] Logging instead of print statements
- [ ] Error messages include helpful context
- [ ] Functions under 50 lines
- [ ] No hardcoded magic numbers (use constants)
- [ ] New dependencies prefer stdlib → open source → closed source (with permission)
- [ ] `requirements.txt` updated if dependencies changed

## When to Apply This Skill

Use this skill for:
- Writing new Python modules or scripts
- Reviewing Python code for standards compliance
- Refactoring existing code to meet professional standards
- Converting quick prototypes to production-ready code
- Setting up new Python projects with proper structure

The goal is production-ready code that's maintainable, testable, and meets the standards expected in a professional environment.
