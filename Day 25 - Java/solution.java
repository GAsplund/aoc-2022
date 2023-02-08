//package com.gasplund.aoc2022.day25;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.lang.Math;

public class solution {

	public static void main(String[] args) {
        List<SNAFU> numbers = new ArrayList<>();
        long totalSum = 0;
		BufferedReader reader;

		try {
			reader = new BufferedReader(new FileReader("input.txt"));
			String line = reader.readLine();

			while (line != null) {
				//System.out.println(line);
                numbers.add(new SNAFU(line));
				line = reader.readLine();
			}

			reader.close();

            for (SNAFU n : numbers) {
                totalSum += n.toLong();
            }
		} catch (IOException e) {
			e.printStackTrace();
		}
        System.out.println(totalSum);
        System.out.println(SNAFU.fromLong(totalSum));
	}

    static class SNAFU {
        static char[] characters = new char[]{'=', '-', '0', '1', '2'};
        private String value;

        public SNAFU(String value) {
            if (value.length() == 0) this.value = "0"; 
            else this.value = value;
        }

        @Override
        public String toString() {
            return this.value;
        }

        public static SNAFU fromLong(long num) {
            long remainder = num;
            StringBuilder newNumber = new StringBuilder();
            while (true) {
                newNumber.insert(0, characters[(int)((remainder + 2) % 5)]);
                remainder = (remainder + 2) / 5;
                if (remainder == 0) break;
            }
            return new SNAFU(newNumber.toString());
        }

        public static int digitToInt(char c) {
            switch (c) {
                case '=':
                    return -2;
                case '-':
                    return -1;
                case '0':
                    return 0;
                case '1':
                    return 1;
                case '2':
                    return 2;
                default:
                    return 0;
            }
        }

        public long toLong() {
            char[] nums = this.value.toCharArray();
    
            long sum = 0;
            int j = 0;
            for (int i = nums.length - 1; i >= 0; i--) {
                sum += digitToInt(nums[i]) * Math.pow(5, j);
                j++;
            }
            return sum;
        }
    }

}