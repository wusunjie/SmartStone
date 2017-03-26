#include <stdio.h>

int main(void)
{
#if 0
	Student student = STUDENT__INIT;
	student.has_age = 1;
	student.age = 3;
	Student *msg = NULL;
	uint8_t *buf = NULL;
	student__pack(&student, buf);
	msg = student__unpack(NULL, student__get_packed_size(&student), buf);
	if (msg->has_age) {
		printf("hello world %ld\n", msg->age);
	}
#endif
	printf("Hello World\n");
	return 0;
}
