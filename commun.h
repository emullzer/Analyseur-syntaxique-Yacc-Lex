#ifndef COMMUN_H
#define COMMUN_H

typedef struct {
    int type;      // 0 = INT, 1 = STRING
    int vInt;
    char* vStr;
} expressionVal;

#endif