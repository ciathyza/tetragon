/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tetragon.util.number
{
	/**
	 * Provides a set of methods for rolling multi-sided dice.
	 */
	public final class Dice
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Rolls a specified amount of four sided dice.
		 * 
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function fourSided(diceCount:int = 1):int
		{
			return roll(4, diceCount);
		}
		
			
		/**
		 * Rolls a specified amount of six sided dice.
		 * 
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function sixSided(diceCount:int = 1):int
		{
			return roll(6, diceCount);
		}
		
		
		/**
		 * Rolls a specified amount of eight sided dice.
		 * 
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function eightSided(diceCount:int = 1):int
		{
			return roll(8, diceCount);
		}
		
		
		/**
		 * Rolls a specified amount of ten sided dice.
		 * 
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function tenSided(diceCount:int = 1):int
		{
			return roll(10, diceCount);
		}
		
		
		/**
		 * Rolls a specified amount of twelve sided dice.
		 * 
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function twelveSided(diceCount:int = 1):int
		{
			return roll(12, diceCount);
		}
		
		
		/**
		 * Rolls a specified amount of twenty sided dice.
		 * 
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function twentySided(diceCount:int = 1):int
		{
			return roll(20, diceCount);
		}
		
		
		/**
		 * Rolls a percentile dice (1% to 100%). This method rolls a percentile dice
		 * like it is rolled with two realistic ten sided dice where both dice specify
		 * a digit for the percentage resulting in 0 to 99 + 1.
		 * 
		 * @return The rolled die.
		 */
		public static function percentile():int
		{
			return int((roll(10) - 1) + "" + (roll(10) - 1)) + 1;
		}
		
		
		/**
		 * Rolls a random boolean result based on the chance value. Returns true or false
		 * based on the chance value (default 50%). For example if you wanted a player to
		 * have a 30% chance of getting a bonus, call chance(30) - true means the chance
		 * passed, false means it failed.
		 * 
		 * @param percent The chance of receiving the value. Should be given as a int
		 *         between 0 and 100 (effectively 0% to 100%).
		 * @return true if the roll passed, or false if not.
		 */
		public static function chance(percent:int = 50):Boolean
		{
			if (percent <= 0) return false;
			else if (percent >= 100) return true;
			else return (Math.random() * 100 <= percent);
		}
		
		
		/**
		 * Rolls a set of dice with the specified maximum number.
		 * 
		 * @param max The maximum value of a single die.
		 * @param diceCount The amount of dice to roll.
		 * @return The rolled die.
		 */
		public static function roll(max:int, diceCount:int = 1):int
		{
			var v:int = 0;
			for (var i:int = 0; i < diceCount; i++)
			{
				v += 1 + (Math.random() * max);
			}
			return v;
		}
	}
}
