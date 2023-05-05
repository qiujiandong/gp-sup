import cv2 as cv

frame_num = 10 # max is 1069
startAddr = 0xC0000000
len = (frame_num * 327680) >> 3
type = 0

# type
# 0. 64bit Hex TI-style
# 1. 64bit Hex C-style (带0x前缀)
# 2. 64bit Floating Point
# 3. Exponential Float (指数表示)
# 4. 32bit Hex TI-style
# 5. 32bit Hex C-style
# 6. 32bit Signed Int
# 7. 32bit Unsigned Int
# 8. 32bit Binary
# 9. 32bit Floating Point
# 10. 32bit Exponential Float
# 11. 16bit Hex TI-style
# 12. 16bit Hex C-style
# 13. 16bit Signed Int
# 14. 16bit Unsigned Int
# 15. 16bit Binary
# 16. 8bit Hex TI-style
# 17. 8bit Hex C-style
# 18. 8bit Signed Int
# 19. 8bit Unsigned Int
# 20. 8bit Binary
# 21. Character
# 22. Packed Char

fp_dst = open('./images.dat', 'w')
fp_dst.write('1651 9 ' + '{:x}'.format(startAddr) + ' 0 ' + '{:x} '.format(len) + '{:x}'.format(type) + '\n')
for i in range(frame_num): 
    img = cv.imread('images/' + str(i) + '.bmp')
    [h, w, c] = img.shape
    print('writing image ' + str(i + 1) + '/' + str(frame_num))

    strLine = ''
    for m in range(h):
        for n in range(w):
            strLine = '{:02x}'.format(img.item(m, n, 0)) + strLine
            if((n + 1) % 8 == 0):
                fp_dst.write(strLine + '\n')
                strLine = ''
fp_dst.close()
