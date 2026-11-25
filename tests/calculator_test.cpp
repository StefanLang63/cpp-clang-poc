#include "calculator.h"

#include <gtest/gtest.h>

TEST(CalculatorTest, Add) {
    Calculator calc;
    EXPECT_DOUBLE_EQ(calc.add(2, 3), 5.0);
}

TEST(CalculatorTest, Subtract) {
    Calculator calc;
    EXPECT_DOUBLE_EQ(calc.subtract(5, 3), 2.0);
}

TEST(CalculatorTest, Multiply) {
    Calculator calc;
    EXPECT_DOUBLE_EQ(calc.multiply(4, 3), 12.0);
}

TEST(CalculatorTest, DivideByNonZero) {
    Calculator calc;
    EXPECT_DOUBLE_EQ(calc.divide(6, 3), 2.0);
}

TEST(CalculatorTest, DivideByZeroThrows) {
    Calculator calc;
    EXPECT_THROW(calc.divide(1, 0), std::invalid_argument);
}
