#include "fun_c.h"

std::string funC()
{
    return funA() + funB() + "<From funC>";
}
