import QtTest 1.0
import QtQuick 2.7

TestCase {
    name: "Test_tst_login"
    when: windowShown

    function test_math() {
        compare(2 + 2, 4, "2 + 2 = 4")
    }

    function test_fail() {
        compare(2 + 2, 5, "2 + 2 = 5")
    }
}
