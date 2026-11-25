#include "calculator.h"

#include <iostream>

int main() {
    Calculator calc;

    std::cout << "2 + 3 = " << calc.add(2, 3) << "\n";
    std::cout << "2 - 3 = " << calc.subtract(2, 3) << "\n";
    std::cout << "2 * 3 = " << calc.multiply(2, 3) << "\n";
    std::cout << "6 / 3 = " << calc.divide(6, 3) << "\n";

    return 0;
}
