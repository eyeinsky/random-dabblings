// set up primitive debugging

debugFlag = false

if (debugFlag) {
    var debug = function () {
	// the spread operator would do it, but let's keep it ES5
	var str = Array.prototype.slice.call(arguments).reduce(function(acc, str) {
	    return acc + ' ' + str
	})
	console.log(str)
    }
} else {
    var debug = function () {} // don't do anything
}


// map from roman digit to their values

var valueOf = {
    I:    1,
    V:    5,
    X:   10,
    L:   50,
    C:  100,
    D:  500,
    M: 1000,
}


// parse a roman number to decreasing chunks in backward order

function parse(str) {
    var str = str.toUpperCase().split('').reverse().join('')
    /* ^ We uppercase and reverse the input string since we'll be
     * processing it from back to front. */

    var chunks = [] // this is what we return
    var lastIndex = str.length - 1

    for(var i = 0; i <= lastIndex;) {
	var currentMax = str[i]
	var currentChunk = currentMax
	debug('starting with i', i, 'current max is', currentMax)
	if (i === lastIndex) {
	    /* i is last index -- push the current chunk and exit the
	     * function. */
	    chunks.push(currentChunk)
	    return chunks
	} else {
	    /* Scan for lower roman digits than current max and append
	     * them to current chunk. */
	    for (var j = i + 1; j <= lastIndex; j++) {
		var nextChar = str[j]
		if (valueOf[nextChar] < valueOf[currentMax]) {
		    /* Next char is lower than the current, hence
		     * belongs to the current chunk -- lets append it.
		     */
		    currentChunk = currentChunk + nextChar
		    if (j === lastIndex) {
			/* j is the last index -- push the current
			 * chunk and exit function. */
			chunks.push(currentChunk)
			return chunks
		    } else {
			/* Otherwise we go to the next iteration of
			 * the current loop -- scanning for more
			 * characters lower than the current max. This
			 * is just a documentational else branch that
			 * doesn't need to be here. */
		    }
		} else {
		    /* j belongs to next chunk. Let's push the current
		     * chunk, set i to j, break out of the inner loop
		     * and start over. */
		    chunks.push(currentChunk)
		    i = j
		    debug( 'pushing chunk', currentChunk
			 , 'since next char', nextChar, '(' + valueOf[nextChar] + ')'
			 , 'is not lower than current max'
			 , currentMax, '(' + valueOf[currentMax] + ')')
		    debug('i is', i)
		    break
		}
	    }
	}
    }
    debug('chunks', chunks)
    debug('parsing done')
    return chunks
}

function chunkToNumber(chunk) {
    var values = chunk.split('').map(function(chr) {
	return valueOf[chr]
    })
    debug('values', values)
    var result = values.reduce(function(acc, n) {
	return acc - n
    })
    return result
}

function romanToNumber(str) {
    var chunks = parse(str)
    debug(chunks)
    var numbers = chunks.map(chunkToNumber)
    var sum = numbers.reduce(function (a, b) {
	return a + b
    })
    debug('numbers', numbers)
    debug('sum', sum)
    return sum
}

function test(roman, expected) {
    var result = romanToNumber(roman)
    if (result !== expected) {
	console.log('FAIL:', roman, '!==', expected, 'but result was', result)
    } else {
	console.log('OK:', roman, '===', expected, 'as expected')
    }
}

function main() {
    test("MDCLIIIX", 1657)
    test('MMMDXXVII', 3527)
    test('MCXLI', 1141)
    test('MMCXCII', 2192)
    test('DCLIV', 654)
    test('CDXXVII', 427)
    test('MMMDXXV', 3525)
    test('MMMCCXIV', 3214)
    test('MMCMLIX', 2959)
    test('MXCV', 1095)
    test('MMDCCCLXVI', 2866)
    test('CMXCIX', 999)
    test('XCIX', 99)
    test('MMDCCCXCVI', 2896)
    test('DCCCLXXXVIII', 888)
    test('MMMDCCCLVI', 3856)
    test('IM', 999) // not legal, but parses
    test('MDCCCCLXXXXVIIII', 1999)
    test('MIM', 1999) // not legal, but parses

}

main()

/* NOTE: Not sure if this is entirely bug-free, property based
   testing and/or round-trip testing would be a better method to
   determine this. But I couldn't find a roman numerla which would
   fail the test.

   Works with at least node v4.2.6.
 */
