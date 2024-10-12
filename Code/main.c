/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-10-2024 17:08:19
 *  Last modified : 12-10-2024 22:38:14
 *  File : main.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "src/geometry.h"
#include "src/persDiag.h"
#include "src/misc.h"

int main(){
    // Routine principale
    PointCloud *X = pointCloudLoad("data/example.dat");
    Filtration *filt = buildFiltration(*X);
    PersistenceDiagram *pd = PDCreate(filt, X);
    PDExport(pd, "exportedPD/pd_example.dat");
    PDFree(pd);
    filtrationFree(filt);
    pointCloudFree(X);
    return 0;
}