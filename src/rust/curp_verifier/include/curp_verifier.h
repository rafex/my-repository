#ifndef CURP_VERIFIER_H
#define CURP_VERIFIER_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

bool verify_curp(const char *curp);

#ifdef __cplusplus
}
#endif

#endif // CURP_VERIFIER_H