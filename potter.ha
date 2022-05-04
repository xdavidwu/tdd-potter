fn price(books: []int) int = {
	return 0;
};

@test fn basics() void = {
	assert(price([]) == 0);
	assert(price([1]) == 8);
	assert(price([2]) == 8);
	assert(price([3]) == 8);
	assert(price([4]) == 8);
	assert(price([1, 1, 1]) == 8 * 3);
};
