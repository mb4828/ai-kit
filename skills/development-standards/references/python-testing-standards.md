---
name: python-testing-standards
description: Enforce rigorous Python testing standards including meaningful assertions, minimum code coverage, proper test isolation, edge case handling, and prevention of always-passing tests. Use when writing, reviewing, or improving Python test suites to ensure tests actually validate correctness rather than providing false confidence.
---

# Python Testing Standards

Apply these standards when writing or reviewing test code.

## Core Principles

- **Tests must fail when code is broken** — A test that never fails provides false confidence
- **Coverage without assertions is worthless** — Running code doesn't mean testing it
- **Test the contract, not the implementation** — Verify what the code does, not how it does it

## Coverage Requirements

**Minimum 60% line coverage** for production code:
```bash
pytest --cov=myapp --cov-report=html --cov-report=term-missing
```

**Exclude from coverage:** `if __name__ == "__main__"` blocks, defensive assertions, deprecated code, third-party code

**Don't chase 100%** — Focus on meaningful coverage of business logic over rare error paths

## Avoiding Superfluous Tests

**Red flags for worthless tests:**

### 1. Always-Passing Tests

**BAD - Test passes even when code is broken:**
```python
def calculate_total(items: List[float]) -> float:
    """Sum a list of numbers."""
    return sum(items)

# WORTHLESS TEST - No assertion
def test_calculate_total():
    result = calculate_total([1.0, 2.0, 3.0])
    # Test passes whether result is 6.0, 0.0, or anything else!
```

**GOOD - Test actually validates behavior:**
```python
def test_calculate_total():
    result = calculate_total([1.0, 2.0, 3.0])
    assert result == 6.0, f"Expected 6.0, got {result}"
```

### 2. Tautological Tests

**BAD - Test just repeats the implementation:**
```python
def calculate_discount(price: float, pct: float) -> float:
    return price * (1 - pct)

# WORTHLESS - Just re-implements the function
def test_calculate_discount():
    price, pct = 100.0, 0.2
    expected = price * (1 - pct)  # Same logic as function!
    assert calculate_discount(price, pct) == expected
```

**GOOD - Test uses independent calculation:**
```python
def test_calculate_discount():
    # Clear business case: 20% off $100 is $80
    assert calculate_discount(100.0, 0.2) == 80.0
    
    # Edge case: 0% discount
    assert calculate_discount(100.0, 0.0) == 100.0
    
    # Edge case: 100% discount
    assert calculate_discount(100.0, 1.0) == 0.0
```

### 3. Tests Without Assertions

**BAD - Code runs but nothing is verified:**
```python
def test_process_data():
    data = pd.DataFrame({"value": [1, 2, 3]})
    result = process_data(data)
    # No assertion - test passes as long as no exception raised!
```

**GOOD - Verify the actual results:**
```python
def test_process_data():
    data = pd.DataFrame({"value": [1, 2, 3]})
    result = process_data(data)
    
    assert len(result) == 3, "Should preserve row count"
    assert "processed_value" in result.columns, "Should add processed column"
    assert result["processed_value"].sum() == 6, "Should double the values"
```

### 4. Overly Permissive Assertions

**BAD - Assertion is too weak to catch bugs:**
```python
def test_calculate_returns():
    returns = calculate_returns(prices)
    assert len(returns) > 0  # Way too weak!
    assert returns is not None  # Meaningless
    assert isinstance(returns, pd.Series)  # Type only, not correctness
```

**GOOD - Strong, specific assertions:**
```python
def test_calculate_returns():
    prices = pd.Series([100, 110, 105, 120])
    returns = calculate_returns(prices)
    
    # Verify specific values
    expected = pd.Series([0.10, -0.0455, 0.1429], index=prices.index[1:])
    pd.testing.assert_series_equal(returns, expected, atol=1e-4)
```

### 5. Mocking Everything

**BAD - Mocking obscures actual behavior:**
```python
@patch('myapp.calculate_risk')
@patch('myapp.get_prices')
def test_portfolio_value(mock_prices, mock_risk):
    mock_prices.return_value = pd.Series([100, 200])
    mock_risk.return_value = 0.15
    
    # This doesn't test anything real!
    result = calculate_portfolio_value()
    assert result > 0
```

**GOOD - Test real code paths with minimal mocking:**
```python
def test_portfolio_value():
    # Use real data and real functions
    prices = pd.Series([100, 200], index=['AAPL', 'GOOGL'])
    weights = pd.Series([0.6, 0.4], index=['AAPL', 'GOOGL'])
    
    result = calculate_portfolio_value(prices, weights)
    
    # Real calculation: 0.6 * 100 + 0.4 * 200 = 140
    assert result == 140.0
```

## Test Structure

**Directory layout:** Group test files by the package they cover. The `tests/` tree should mirror the production
package structure, with one subdirectory per package when a project has multiple packages or subpackages.

**File naming:** `test_*.py` mirroring source modules (`portfolio.py` → `test_portfolio.py`). For example:

```text
myapp/
  core/models.py
  strategies/nearest_car.py
tests/
  core/test_models.py
  strategies/test_nearest_car.py
```

Top-level modules may keep their tests at the test root (`main.py` → `tests/test_main.py`).

**Function naming:** `test_<function>_<scenario>`:
```python
def test_calculate_var_with_insufficient_data_raises_error():
    """Test that VaR calculation raises error with too few data points."""
    pass
```

**Docstrings:** Every test needs a docstring explaining what it verifies

## Test Coverage Scenarios

**Test these for every function:**

1. **Happy path** — Valid input produces expected output
2. **Edge cases** — Empty, single item, identical values, boundary values (0, max, negative)
3. **Error conditions** — Invalid input raises appropriate exceptions with clear messages
4. **Type validation** — Wrong types raise TypeError

## Test Isolation

**Use fixtures for shared setup:**
```python
@pytest.fixture
def sample_prices():
    """Provide sample price data for testing."""
    return pd.DataFrame({...})

def test_optimization(sample_prices):
    """Test optimization with sample data."""
    result = optimize_portfolio(sample_prices)
    assert result is not None
```

**No shared mutable state:**
```python
# BAD - Tests affect each other
SHARED_DATA = []
def test_append(): SHARED_DATA.append("X")

# GOOD - Independent data per test
def test_append():
    data = []
    data.append("X")
```

## Parameterized Tests

Test multiple cases efficiently:
```python
@pytest.mark.parametrize("price,discount,expected", [
    (100.0, 0.0, 100.0),  # No discount
    (100.0, 0.5, 50.0),   # 50% off
    (100.0, 1.0, 0.0),    # 100% off
])
def test_calculate_discount(price, discount, expected):
    """Test discount calculation."""
    assert calculate_discount(price, discount) == expected
```

## Advanced Testing

**Async code:**
```python
@pytest.mark.asyncio
async def test_fetch_data():
    """Test async data fetching."""
    async with Client() as client:
        data = await client.fetch(['AAPL'])
        assert 'AAPL' in data
```

**Data pipelines** — Test transformations preserve invariants (row counts, column types, value ranges)

**Property-based testing** — Use `hypothesis` for complex logic with random inputs

**Performance** — Benchmark critical functions with `pytest-benchmark`

**Integration** — Test multi-component workflows end-to-end

## Quality Checklist

- [ ] Descriptive test names and docstrings
- [ ] Every test has meaningful assertions
- [ ] Tests fail when code is broken (verify by breaking it)
- [ ] Edge cases covered (empty, boundaries, errors)
- [ ] No tautological tests (re-implementing the function)
- [ ] Minimal mocking (test real code paths)
- [ ] Fixtures used for shared setup
- [ ] No shared mutable state
- [ ] Tests are fast (< 1s for unit tests)
- [ ] Coverage ≥ 60%
