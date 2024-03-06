#include "beagleboneblack.h"
#include <stdint.h>
#include <stdarg.h>

static inline int _putu(uint32_t v, int sz, int zp)
{
	char buf[11];
	int bp, r, b;

	bp = 10;
	buf[bp] = '\0';
	while (v != 0) {
		uint32_t t = v / 10;
		r = v - t * 10;
		v = t;
		buf[--bp] = (char)(r + '0');
	}
	if (bp == 10)
		buf[--bp] = '0';
	if (!zp)
		b = putcn(' ', sz-(10-bp));
	else
		b = putcn('0', sz-(10-bp));
	b += puts(buf + bp);
	return b;
}

static int _putd(int32_t v)
{
	int w = 0;
	if (v < 0) {
		w += putc('-');
		v = -v;
	}
	w += _putu(v, 1, 0);
	return w;
}

static int _puth(uint32_t v, int sz, int zp)
{
	unsigned int i, d, bp = 0;
	uint32_t mask;
	char buf[9];

	mask = 0xf0000000u;
	for (i = 0; mask != 0; i += 4, mask >>= 4) {
		d = (v & mask) >> (28 - i);
		if (d == 0 && bp == 0)
			continue;
		buf[bp++] = d + (d > 9 ? 'a' - 10 : '0'); 
	}
	if (bp == 0)
		buf[bp++] = '0';
	buf[bp] = '\0';
	if (!zp)
		i = putcn(' ', sz-bp);
	else
		i = putcn('0', sz-bp);
	i += puts(buf);
	return i;
}

static int _putf(double v, int prec)
{
	int i, w = 0;
	if (v < 0.0) {
		w += putc('-');
		v = -v;
	}
	w += _putu(v,0,0);
	w += putc('.');
	for (i = 0; i < prec; ++i) {
		v = v - (int)v;
		v = v * 10;
		w += putc('0' + (int)v) + (i+1==prec && v-(int)v>=.5);
	}
	return w;
}

static int _putc(int ch)
{
	int v = putc(ch);
	if (ch == '\n')
		v += putc('\r');
	return v;
}

int printf(const char *p, ...)
{
	int rc = 0, precision, zero_padded;
	va_list ap;

	va_start(ap, p);
	while (*p != '\0') {
		if (*p != '%') {
			rc += _putc(*p++);
			continue;
		}
		precision = 0;
		zero_padded = 0;
again:
		switch (*++p) {
			case 's':
				rc += puts(va_arg(ap, char *));
				break;
			case 'c':
				rc += putc((char)va_arg(ap, int));
				break;
			case 'u':
				rc += _putu(va_arg(ap, uint32_t), precision, zero_padded);
				break;
			case 'd':
				rc += _putd(va_arg(ap, int32_t));
				break;
			case 'x':
				rc += _puth(va_arg(ap, uint32_t), precision, zero_padded);
				break;
			case 'f':
				rc += _putf(va_arg(ap, double), precision);
				break;
			default:
				if (*p == '0' && precision == 0) {
					zero_padded = 1;
					goto again;
				}
				if (*p >= '0' && *p <= '9') {
					precision = precision * 10 + (*p - '0');
					goto again;
				}
				rc += _putc(*p++);
				continue;
		}
		p++;
	}
	va_end(ap);
	return rc;
}

/*
vim: tabstop=8 softtabstop=8
*/

