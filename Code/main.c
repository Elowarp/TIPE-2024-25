/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-10-2024 17:08:19
 *  Last modified : 10-10-2024 22:34:43
 *  File : main.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "structures/geometry.h"
#include "persDiag.h"
#include "misc.h"

int main(){
    // Routine principale
    PointCloud *X = pointCloudLoad("data/example.dat");
    Filtration *filt = buildFiltration(*X);
    filtrationPrint(filt, X->size);
    PersistenceDiagram *pd = PDCreate(filt, X);
    PDExport(pd, "exportedPD/pd_example.dat");
    PDFree(pd);
    filtrationFree(filt);
    pointCloudFree(X);
    return 0;
}