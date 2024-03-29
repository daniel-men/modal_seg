

class Base64Util {
  static final List<String> _base64Char = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", 
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "+", "/",
  ];

  static List<int> base64Decoder(String str) {
    /**
     * 由于后台说sun公司的某些旧的包处理出来的base64字符串包含换行符，所以先将其删除
     * Because the background said that some old packages of Sun company processed the base64 string contains a newline character, so delete it first
     */
    str = str.replaceAll("\n", "");
    List<int> list = [];
    /**
     * 由于需要将传入的字符串按4字节分组，需要先判断其长度是否为4的整数倍
     * Since the incoming string needs to be grouped by 4 bytes, it is necessary to first determine whether its length is an integer multiple of 4
     */
    if (str.length % 4 == 0) {
      /**
       * 循环取字符串的字符，每次取4个
       * Take the characters of the string in a loop, taking 4 each time
       */
      for (int i = 0; i < str.length; i += 4) {
        String char1 = str.substring(i, i + 1);
        String char2 = str.substring(i + 1, i + 2);
        String char3 = str.substring(i + 2, i + 3);
        String char4 = str.substring(i + 3, i + 4);

        /**
         * 将取出的字符按照字码表进行转换成数字，当为等于号时，则不进行处理，因为等于号是填充符
         * Convert the retrieved character into a number according to the code table.
         *  When it is an equal sign, it will not be processed because the equal sign is a filler
         */
        int code1 = _base64Char.indexOf(char1);
        int code2 = _base64Char.indexOf(char2);
        late int code3;
        if ("=" != char3) {
          code3 = _base64Char.indexOf(char3);
        }
        late int code4;
        if ("=" != char4) {
          code4 = _base64Char.indexOf(char4);
        }

        /**
         * 将转换后的数字进行分割处理，当对应字符为等于号，则不进行分割处理
         * Split the converted number. When the corresponding character is an equal sign, the split will not be performed
         */
        /**
         * 将第一个字节与0x3F，得到低6位，然后左移2位，腾出低2位的位置
         * Combine the first byte with 0x3F to get the lower 6 bits, then shift 2 bits to the left to make room for the lower 2 bits
         * 然后将第二个字节与0x30，清除高2位和低4位，再右移4位，
         * 与前一个高6位相加，得到第一个新字节
         * Then the second byte is 0x30, the high 2 bits and low 4 bits are cleared, and then 4 bits are shifted to the right,
         * Add the previous high 6 bits to get the first new byte
         */
        int decode1 = ((code1 & 0x3F) << 2) + ((code2 & 0x30) >> 4);
        /**
         * 将第二个字节与0x0F，得到低4位，然后左移4位，腾出低4位的位置
         * 然后将第三个字节与0x3C，清除高2位和低2位，再右移2位，
         * 与前一个高4位相加，得到第二个新字节
         * Combine the second byte with 0x0F to get the lower 4 bits, and then shift 4 bits to the left to make room for the lower 4 bits
         * Then the third byte and 0x3C, clear the high 2 bits and low 2 bits, and then shift 2 bits to the right,
         * Add the previous high 4 bits to get the second new byte
         */
        int? decode2;
        if ("=" != char3) {
          decode2 = ((code2 & 0x0F) << 4) + ((code3 & 0x3C) >> 2);
        }
        /**
         * 将第三个字节与0x03，得到低2位，然后左移6位，腾出低6位的位置
         * 然后直接与第四个字节相加，得到第三个新字节
         * Combine the third byte with 0x03 to get the lower 2 bits, and then shift 6 bits to the left to make room for the lower 6 bits
         * Then directly add to the fourth byte to get the third new byte
         */
        int? decode3;
        if ("=" != char4) {
          decode3 = ((code3 & 0x03) << 6) + code4;
        }

        list.add(decode1);
        if ("=" != char3) {
          list.add(decode2!);
        }
        if ("=" != char4) {
          list.add(decode3!);
        }
      }
    }
    return list;
  }

  static String base64Encoder(List<int> list) {
    StringBuffer sb = StringBuffer();
    /**
     * 由于需要将传入的数组按3字节分组，所以先处理3的最大整数倍的长度的内容
     */
    int remainder = list.length % 3;
    int size = list.length - remainder;
    /**
     * 循环取数组里的字节，每次取3个
     */
    for (int i = 0; i < size; i += 3) {
      int code1 = list[i];
      int code2 = list[i + 1];
      int code3 = list[i + 2];
      /**
       * 首先将第一字节右移2位，得到左6位，与上0x3F，高2位置0，得到第一个6位
       * 然后在编码表里进行转码，得到新组的第一字节
       */
      int encode1 = (code1 >> 2) & 0x3F;
      /**
       * 接着将第一字节与0x03，即00000011，得到低2位，然后左移4位，
       * 然后将第二字节右移4位，做加法运算，得到第二个6位，转码得到新组的第二字节
       */
      int encode2 = ((code1 & 0x03) << 4) + ((code2 >> 4) & 0x0F);
      /**
       * 将第二字节与0x0F，即00001111，得到低4位，然后左移2位，
       * 然后将第三字节右移6位，得到高2位，做加法运算，得到第三个6位，转码得到新组的第三字节
       */
      int encode3 = ((code2 & 0x0F) << 2) + ((code3 >> 6) & 0x03);
      /**
       * 最后将第三字节与上0x3F，清除高2位，得到低6位，即第四个6位，转码得到新组的第四字节
       */
      int encode4 = code3 & 0x3F;

      String char1 = _base64Char[encode1];
      String char2 = _base64Char[encode2];
      String char3 = _base64Char[encode3];
      String char4 = _base64Char[encode4];

      sb.write(char1);
      sb.write(char2);
      sb.write(char3);
      sb.write(char4);
    }
    /**
     * 当原文不是3的整数倍时，则需要继续处理多出的1或2个字节
     */
    if (remainder != 0) {
      /**
       * 既然多出内容，那么至少多一个，所以第一字节直接取
       * 对第二字节需要判断
       */
      int code1 = list[size];
      int code2 = 0;
      if (remainder == 2) {
        code2 = list[size + 1];
      }
      /**
       * 新组第一二字节可直接取6位然后转码
       */
      int encode1 = (code1 >> 2) & 0x3F;
      int encode2 = ((code1 & 0x03) << 4) + ((code2 >> 4) & 0x0F);
      String char1 = _base64Char[encode1];
      String char2 = _base64Char[encode2];
      /**
       * 如果原文只多出1字节，那么新组第三字节肯定为0，那么按照规则，空字符用 '=' 代替
       * 如果多出2字节，则还继续进行取6位、转码的运算，
       */
      int encode3;
      String char3 = "=";
      if (remainder == 2) {
        encode3 = (code2 & 0x0F) << 2;
        char3 = _base64Char[encode3];
      }
      /**
       * 由于最多多出2字节，所以新组第四字节肯定没有值可以取，也就是空字符，所以直接转换为 '='
       */
      String char4 = "=";

      sb.write(char1);
      sb.write(char2);
      sb.write(char3);
      sb.write(char4);
    }

    return sb.toString();
  }
}