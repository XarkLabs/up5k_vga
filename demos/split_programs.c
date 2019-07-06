#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned char buffer[32*1024];

int main(int argc, char **argv)
{
    FILE *fp = NULL;
    size_t bytes = 0;
    int count = 0;

    if (argc != 2)
    {
        printf("Usage: %s <basic_programs.rom>\n", argv[0]);
        printf("       Splits BASIC individual programs from ROM binary\n\n");
        return EXIT_FAILURE;
    }

    printf("Splitting BASIC programs out of \"%s\"...\n", argv[1]);
    fp = fopen(argv[1], "r");

    while (!feof(fp))
    {
        memset(buffer, 0xff, sizeof(buffer));
        bytes = fread(buffer, 1, sizeof(buffer), fp);

        if (bytes != 0 && buffer[0] != 0xff)
        {
            FILE *ofp = NULL;
            char oname[32] = {0};
            int size;
            for (size = 0; size < sizeof(buffer);size++)
            {
                if (buffer[size] == 0xff)
                    break;
            }
            sprintf(oname, "program_%02d.bas", count);
            printf("Saving slot %02d as \"%s\" size %d (0x%04x)\n", count, oname, size, size);
            ofp = fopen(oname, "w");
            if (ofp == NULL)
            {
                perror("Error creating");
                exit(EXIT_FAILURE);
            }
            if (fwrite(buffer, size, 1, ofp) != 1)
            {
                perror("Error writing");
                exit(EXIT_FAILURE);
            }
            fclose(ofp);
            count++;
        }
    }

    fclose(fp);
    printf("Done\n");
    return 0;
}
