#include "calculator.h"

#include <stdexcept>

double Calculator::add(double lhs, double rhs) const {
    return lhs + rhs;
}

double Calculator::subtract(double lhs, double rhs) const {
    return lhs - rhs;
}

double Calculator::multiply(double lhs, double rhs) const {
    return lhs * rhs;
}

double Calculator::divide(double lhs, double rhs) const {
    if (rhs == 0.0) {
        throw std::invalid_argument("division by zero");
    }
    return lhs / rhs;
}
