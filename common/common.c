#include "common.h"
#include <dirent.h>
#include <stdio.h>
#include <string.h>

int getAllTestcase(char filename[][256])
{
	/// \todo student should fill this function
	int i = 0;
	struct dirent *file;
	DIR *dp = opendir("testcase");
	char suffix[] = ".cminus";
	if (!dp)
	{
		fprintf(stderr, "open directory error\n");
		return 0;
	}
	file = readdir(dp);
	while (file)
	{
		if (strstr(file->d_name, suffix)) {
			strcpy(filename[i], file->d_name);
			i++;
		}
		file = readdir(dp);
	}
	closedir(dp);
	return i;
}