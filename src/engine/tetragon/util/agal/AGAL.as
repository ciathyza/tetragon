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
package tetragon.util.agal
{
	import tetragon.util.debug.HLog;

	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getTimer;


	/**
	 * An optimized version of Adobe's AGAL mini assembler.
	 * 
	 * TODO Obsolete Version!
	 */
	public class AGAL
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const VERTEX:String			= Context3DProgramType.VERTEX;
		public static const FRAGMENT:String			= Context3DProgramType.FRAGMENT;
		
		/** @private */
		private static const OPMAP:Dictionary		= new Dictionary();
		/** @private */
		private static const REGMAP:Dictionary		= new Dictionary();
		/** @private */
		private static const SAMPLEMAP:Dictionary	= new Dictionary();
		/** @private */
		private static const MAX_NESTING:int		= 4;
		/** @private */
		private static const MAX_OPCODES:int		= 256;
		
		/* masks and shifts */
		/** @private */
		private static const SAMPLER_DIM_SHIFT:uint		= 12;
		/** @private */
		private static const SAMPLER_SPECIAL_SHIFT:uint	= 16;
		/** @private */
		private static const SAMPLER_REPEAT_SHIFT:uint	= 20;
		/** @private */
		private static const SAMPLER_MIPMAP_SHIFT:uint	= 24;
		/** @private */
		private static const SAMPLER_FILTER_SHIFT:uint	= 28;
		
		/* regmap flags */
		/** @private */
		private static const REG_WRITE:uint	= 0x1;
		/** @private */
		private static const REG_READ:uint	= 0x2;
		/** @private */
		private static const REG_FRAG:uint	= 0x20;
		/** @private */
		private static const REG_VERT:uint	= 0x40;
		
		/* opmap flags */
		/** @private */
		private static const OP_SCALAR:uint			= 0x1;
		/** @private */
		private static const OP_INC_NEST:uint		= 0x2;
		/** @private */
		private static const OP_DEC_NEST:uint		= 0x4;
		/** @private */
		private static const OP_SPECIAL_TEX:uint	= 0x8;
		/** @private */
		private static const OP_SPECIAL_MATRIX:uint	= 0x10;
		/** @private */
		private static const OP_FRAG_ONLY:uint		= 0x20;
		/** @private */
		private static const OP_NO_DEST:uint		= 0x80;
		
		/* opcodes */
		/** @private */
		private static const MOV:String = "mov";
		/** @private */
		private static const ADD:String = "add";
		/** @private */
		private static const SUB:String = "sub";
		/** @private */
		private static const MUL:String = "mul";
		/** @private */
		private static const DIV:String = "div";
		/** @private */
		private static const RCP:String = "rcp";
		/** @private */
		private static const MIN:String = "min";
		/** @private */
		private static const MAX:String = "max";
		/** @private */
		private static const FRC:String = "frc";
		/** @private */
		private static const SQT:String = "sqt";
		/** @private */
		private static const RSQ:String = "rsq";
		/** @private */
		private static const POW:String = "pow";
		/** @private */
		private static const LOG:String = "log";
		/** @private */
		private static const EXP:String = "exp";
		/** @private */
		private static const NRM:String = "nrm";
		/** @private */
		private static const SIN:String = "sin";
		/** @private */
		private static const COS:String = "cos";
		/** @private */
		private static const CRS:String = "crs";
		/** @private */
		private static const DP3:String = "dp3";
		/** @private */
		private static const DP4:String = "dp4";
		/** @private */
		private static const ABS:String = "abs";
		/** @private */
		private static const NEG:String = "neg";
		/** @private */
		private static const SAT:String = "sat";
		/** @private */
		private static const M33:String = "m33";
		/** @private */
		private static const M44:String = "m44";
		/** @private */
		private static const M34:String = "m34";
		/** @private */
		private static const IFZ:String = "ifz";
		/** @private */
		private static const INZ:String = "inz";
		/** @private */
		private static const IFE:String = "ife";
		/** @private */
		private static const INE:String = "ine";
		/** @private */
		private static const IFG:String = "ifg";
		/** @private */
		private static const IFL:String = "ifl";
		/** @private */
		private static const IEG:String = "ieg";
		/** @private */
		private static const IEL:String = "iel";
		/** @private */
		private static const ELS:String = "els";
		/** @private */
		private static const EIF:String = "eif";
		/** @private */
		private static const REP:String = "rep";
		/** @private */
		private static const ERP:String = "erp";
		/** @private */
		private static const BRK:String = "brk";
		/** @private */
		private static const KIL:String = "kil";
		/** @private */
		private static const TEX:String = "tex";
		/** @private */
		private static const SGE:String = "sge";
		/** @private */
		private static const SLT:String = "slt";
		/** @private */
		private static const SGN:String = "sgn";
		
		/* registers */
		/** @private */
		private static const VA:String	= "va";
		/** @private */
		private static const VC:String	= "vc";
		/** @private */
		private static const VT:String	= "vt";
		/** @private */
		private static const OP:String	= "op";
		/** @private */
		private static const V:String	= "v";
		/** @private */
		private static const FC:String	= "fc";
		/** @private */
		private static const FT:String	= "ft";
		/** @private */
		private static const FS:String	= "fs";
		/** @private */
		private static const OC:String	= "oc";
		
		/* samplers */
		/** @private */
		private static const D2:String			= "2d";
		/** @private */
		private static const D3:String			= "3d";
		/** @private */
		private static const CUBE:String		= "cube";
		/** @private */
		private static const MIPNEAREST:String	= "mipnearest";
		/** @private */
		private static const MIPLINEAR:String	= "miplinear";
		/** @private */
		private static const MIPNONE:String		= "mipnone";
		/** @private */
		private static const NOMIP:String		= "nomip";
		/** @private */
		private static const NEAREST:String		= "nearest";
		/** @private */
		private static const LINEAR:String		= "linear";
		/** @private */
		private static const CENTROID:String	= "centroid";
		/** @private */
		private static const SINGLE:String		= "single";
		/** @private */
		private static const DEPTH:String		= "depth";
		/** @private */
		private static const REPEAT:String		= "repeat";
		/** @private */
		private static const WRAP:String		= "wrap";
		/** @private */
		private static const CLAMP:String		= "clamp";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _agalcode:ByteArray;
		/** @private */
		private var _error:String;
		/** @private */
		private var _debug:Boolean;
		/** @private */
		private var _verbose:Boolean;
		/** @private */
		private static var _initialized:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AGALMiniAssembler instance.
		 * 
		 * @param debug
		 * @param verbose
		 */
		public function AGAL(debug:Boolean = false, verbose:Boolean = false):void
		{
			_debug = debug;
			_verbose = verbose;
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Assembles a string of AGAL instructions into bytecode.
		 * 
		 * @param mode assemble mode, either AGAL.FRAGMENT or AGAL.VERTEX.
		 * @param source Source string.
		 * @return a ByteArray.
		 */
		public function assemble(mode:String, source:String):ByteArray
		{
			var start:uint = getTimer();
			var isFrag:Boolean = false;
			
			_agalcode = new ByteArray();
			_error = "";
			
			if (mode == FRAGMENT)
			{
				isFrag = true;
			}
			else if (mode != VERTEX)
			{
				_error = "ERROR: mode needs to be \"" + FRAGMENT + "\" or \"" + VERTEX
					+ "\" but is \"" + mode + "\".";
			}
			
			_agalcode.endian = Endian.LITTLE_ENDIAN;
			_agalcode.writeByte(0xa0);					// tag version
			_agalcode.writeUnsignedInt(0x1);			// AGAL version, big endian, bit pattern will be 0x01000000
			_agalcode.writeByte(0xa1);					// tag program id
			_agalcode.writeByte(isFrag ? 1 : 0);		// vertex or fragment
			
			var lines:Array = source.replace(/[\f\n\r\v]+/g, "\n").split("\n");
			var nest:int = 0;
			var nops:int = 0;
			var i:int;
			var lng:int = lines.length;
			
			for (i = 0; i < lng && _error == ""; i++)
			{
				var line:String = new String(lines[i]);
				
				// remove comments
				var startcomment:int = line.search("//");
				if (startcomment != -1) line = line.slice(0, startcomment);
				
				// grab options
				var optsi:int = line.search(/<.*>/g);
				var opts:Array;
				if (optsi != -1)
				{
					opts = line.slice(optsi).match(/([\w\.\-\+]+)/gi);
					line = line.slice(0, optsi);
				}
				
				// find opcode
				var opa:Array = line.match(/^\w{3}/ig);
				var op:OpCode = OPMAP[opa[0]];
				
				// if debug is enabled, output the opcodes
				if (_debug && op)
				{
					log("OPC " + op.name + "\temit:" + op.emit + "\tnreg:" + op.nreg + "\tflags:" + op.flags);
				}
				
				if (!op)
				{
					if (line.length >= 3) log("Bad line " + i + ": " + lines[i], true);
					continue;
				}
				
				line = line.slice(line.search(op.name) + op.name.length);
				
				// nesting check
				if (op.flags & OP_DEC_NEST)
				{
					nest--;
					if (nest < 0)
					{
						_error = "error: conditional closes without open.";
						break;
					}
				}
				if (op.flags & OP_INC_NEST)
				{
					nest++;
					if (nest > MAX_NESTING)
					{
						_error = "error: nesting to deep, maximum allowed is " + MAX_NESTING + ".";
						break;
					}
				}
				if ((op.flags & OP_FRAG_ONLY) && !isFrag)
				{
					_error = "error: opcode is only allowed in fragment programs.";
					break;
				}
				if (_verbose) log("emit opcode=" + op);
				
				_agalcode.writeUnsignedInt(op.emit);
				nops++;
				
				if (nops > MAX_OPCODES)
				{
					_error = "Error: Too many opcodes. Maximum is " + MAX_OPCODES + ".";
					break;
				}
				
				// get operands, use regexp
				var regs:Array = line.match(/vc\[([vof][actps]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][actps]?)(\d*)?(\.[xyzw]{1,4})?/gi);
				if (regs.length != op.nreg)
				{
					_error = "Error: Wrong number of operands. Found " + regs.length + " but expected " + op.nreg + ".";
					break;
				}
				
				var badreg:Boolean = false;
				var pad:uint = 64 + 64 + 32;
				var regLength:uint = regs.length;
				
				for (var j:int = 0; j < regLength; j++)
				{
					var isRelative:Boolean = false;
					var relreg:Array = (regs[j] as String).match(/\[.*\]/ig);
					if (relreg.length > 0)
					{
						regs[j] = (regs[j] as String).replace(relreg[0], "0");
						if (_verbose) log("IS REL");
						isRelative = true;
					}
					
					var res:Array = (regs[j] as String).match(/^\b[A-Za-z]{1,2}/ig);
					var r:Register = REGMAP[res[0]];
					
					// if debug is enabled, output the registers
					if (_debug && r)
					{
						log("REG " + r.name + "\temit:" + r.emit + "\trang:" + r.rang + " \tflags:" + r.flags + "\tlong:\"" + r.long + "\"");
					}
					
					if (!r)
					{
						_error = "error: could not parse operand " + j + " (" + regs[j] + ").";
						badreg = true;
						break;
					}
					
					if (isFrag)
					{
						if (!(r.flags & REG_FRAG))
						{
							_error = "error: register operand " + j + " (" + regs[j] + ") only allowed in vertex programs.";
							badreg = true;
							break;
						}
						if (isRelative)
						{
							_error = "error: register operand " + j + " (" + regs[j] + ") relative adressing not allowed in fragment programs.";
							badreg = true;
							break;
						}
					}
					else
					{
						if (!(r.flags & REG_VERT))
						{
							_error = "error: register operand " + j + " (" + regs[j] + ") only allowed in fragment programs.";
							badreg = true;
							break;
						}
					}
					
					regs[j] = (regs[j] as String).slice((regs[j] as String).search(r.name) + r.name.length);
					// trace( "REGNUM: " +regs[j] );
					var idxmatch:Array = isRelative ? (relreg[0] as String).match(/\d+/) : (regs[j] as String).match(/\d+/);
					var regidx:uint = 0;
					
					if (idxmatch) regidx = uint(idxmatch[0]);
					
					if (r.rang < regidx)
					{
						_error = "error: register operand " + j + " (" + regs[j] + ") index exceeds limit of " + (r.rang + 1) + ".";
						badreg = true;
						break;
					}
					
					var regmask:uint = 0;
					var maskmatch:Array = (regs[j] as String).match(/(\.[xyzw]{1,4})/);
					var isDest:Boolean = (j == 0 && !(op.flags & OP_NO_DEST));
					var isSampler:Boolean = (j == 2 && (op.flags & OP_SPECIAL_TEX));
					var reltype:uint = 0;
					var relsel:uint = 0;
					var reloffset:int = 0;
					
					if (isDest && isRelative)
					{
						_error = "error: relative can not be destination";
						badreg = true;
						break;
					}
					
					if (maskmatch)
					{
						regmask = 0;
						var cv:uint;
						var maskLength:uint = (maskmatch[0] as String).length;
						for (var k:int = 1; k < maskLength; k++)
						{
							cv = (maskmatch[0] as String).charCodeAt(k) - "x".charCodeAt(0);
							if (cv > 2) cv = 3;
							if (isDest) regmask |= 1 << cv;
							else regmask |= cv << ((k - 1) << 1);
						}
						if (!isDest)
						{
							for (; k <= 4; k++)
							{
								regmask |= cv << ((k - 1) << 1);
							}
						}
						// repeat last
					}
					else
					{
						regmask = isDest ? 0xf : 0xe4; // id swizzle or mask
					}
					
					if (isRelative)
					{
						var relname:Array = (relreg[0] as String).match(/[A-Za-z]{1,2}/ig);
						var regFoundRel:Register = REGMAP[relname[0]];
						if (regFoundRel == null)
						{
							_error = "error: bad index register";
							badreg = true;
							break;
						}
						reltype = regFoundRel.emit;
						var selmatch:Array = (relreg[0] as String).match(/(\.[xyzw]{1,1})/);
						if (selmatch.length == 0)
						{
							_error = "error: bad index register select";
							badreg = true;
							break;
						}
						relsel = (selmatch[0] as String).charCodeAt(1) - "x".charCodeAt(0);
						if (relsel > 2) relsel = 3;
						var relofs:Array = (relreg[0] as String).match(/\+\d{1,3}/ig);
						if (relofs.length > 0) reloffset = relofs[0];
						if (reloffset < 0 || reloffset > 255)
						{
							_error = "error: index offset " + reloffset + " out of bounds. [0..255]";
							badreg = true;
							break;
						}
						if (_verbose)
						{
							log("RELATIVE: type=" + reltype + "==" + relname[0] + " sel=" + relsel + "==" + selmatch[0] + " idx=" + regidx + " offset=" + reloffset);
						}
					}
					
					if (_verbose)
					{
						log("  emit argcode=" + r + "[" + regidx + "][" + regmask + "]");
					}
					
					if (isDest)
					{
						_agalcode.writeShort(regidx);
						_agalcode.writeByte(regmask);
						_agalcode.writeByte(r.emit);
						pad -= 32;
					}
					else
					{
						if (isSampler)
						{
							if (_verbose) log("  emit sampler");
							var samplerbits:uint = 5; // type 5
							var optsLength:uint = opts.length;
							var bias:Number = 0;
							for (k = 0; k < optsLength; k++)
							{
								if (_verbose) log("    opt: " + opts[k]);
								var smp:Sampler = SAMPLEMAP[opts[k]];
								// if debug is enabled, output the samplers
								if (_debug && smp)
								{
									log("SMP " + smp.name + "\tflag:" + smp.flag + "\tmask:" + smp.mask);
								}
								if (!smp)
								{
									// todo check that it's a number...
									log("Unknown sampler option: "+opts[k], true);
									bias = Number(opts[k]);
									if (_verbose) log("    bias: " + bias);
								}
								else
								{
									if (smp.flag != SAMPLER_SPECIAL_SHIFT)
									{
										samplerbits &= ~(0xf << smp.flag);
									}
									samplerbits |= uint(smp.mask) << uint(smp.flag);
								}
							}
							
							_agalcode.writeShort(regidx);
							_agalcode.writeByte(int(bias * 8.0));
							_agalcode.writeByte(0);
							_agalcode.writeUnsignedInt(samplerbits);
							
							if (_verbose) log("    bits: " + ( samplerbits - 5 ));
							pad -= 64;
						}
						else
						{
							if (j == 0)
							{
								_agalcode.writeUnsignedInt(0);
								pad -= 32;
							}
							_agalcode.writeShort(regidx);
							_agalcode.writeByte(reloffset);
							_agalcode.writeByte(regmask);
							_agalcode.writeByte(r.emit);
							_agalcode.writeByte(reltype);
							_agalcode.writeShort(isRelative ? (relsel | (1 << 15)) : 0);
							pad -= 64;
						}
					}
				}
				
				// pad unused regs
				for (j = 0; j < pad; j += 8)
				{
					_agalcode.writeByte(0);
				}
				
				if (badreg) break;
			}
			
			if (_error && _error != "")
			{
				_error += "\n  at line " + i + " " + lines[i];
				_agalcode.length = 0;
				log(_error, true);
			}
			
			// trace the bytecode bytes if debugging is enabled
			if (_debug)
			{
				var dbgLine:String = "generated bytecode:";
				var agalLength:uint = _agalcode.length;
				for (var index:uint = 0; index < agalLength; index++)
				{
					if (!(index % 16)) dbgLine += "\n";
					if (!(index % 4)) dbgLine += " ";
					var byteStr:String = int(_agalcode[index]).toString(16).toUpperCase();
					if (byteStr.length < 2) byteStr = "0" + byteStr;
					dbgLine += byteStr;
				}
				log(dbgLine);
			}
			
			if (_verbose)
			{
				log("AGAL assemble time: " + ((getTimer() - start) / 1000) + "s");
			}
			
			return _agalcode;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The error message, or null.
		 */
		public function get error():String
		{
			return _error;
		}
		
		
		/**
		 * Generated AGAL byte code, or null.
		 */
		public function get agalcode():ByteArray
		{
			return _agalcode;
		}
		
		
		/**
		 * Determines whether debug information should be logged or not.
		 * 
		 * @default false
		 */
		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug(v:Boolean):void
		{
			_debug = v;
		}
		
		
		/**
		 * Determines whether debug information should be verbose.
		 * 
		 * @default false
		 */
		public function get verbose():Boolean
		{
			return _verbose;
		}
		public function set verbose(v:Boolean):void
		{
			_verbose = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function init():void
		{
			if (_initialized) return;
			_initialized = true;
			
			// Fill the dictionaries with opcodes and registers
			OPMAP[MOV] = new OpCode(MOV, 2, 0x00, 0);
			OPMAP[ADD] = new OpCode(ADD, 3, 0x01, 0);
			OPMAP[SUB] = new OpCode(SUB, 3, 0x02, 0);
			OPMAP[MUL] = new OpCode(MUL, 3, 0x03, 0);
			OPMAP[DIV] = new OpCode(DIV, 3, 0x04, 0);
			OPMAP[RCP] = new OpCode(RCP, 2, 0x05, 0);
			OPMAP[MIN] = new OpCode(MIN, 3, 0x06, 0);
			OPMAP[MAX] = new OpCode(MAX, 3, 0x07, 0);
			OPMAP[FRC] = new OpCode(FRC, 2, 0x08, 0);
			OPMAP[SQT] = new OpCode(SQT, 2, 0x09, 0);
			OPMAP[RSQ] = new OpCode(RSQ, 2, 0x0a, 0);
			OPMAP[POW] = new OpCode(POW, 3, 0x0b, 0);
			OPMAP[LOG] = new OpCode(LOG, 2, 0x0c, 0);
			OPMAP[EXP] = new OpCode(EXP, 2, 0x0d, 0);
			OPMAP[NRM] = new OpCode(NRM, 2, 0x0e, 0);
			OPMAP[SIN] = new OpCode(SIN, 2, 0x0f, 0);
			OPMAP[COS] = new OpCode(COS, 2, 0x10, 0);
			OPMAP[CRS] = new OpCode(CRS, 3, 0x11, 0);
			OPMAP[DP3] = new OpCode(DP3, 3, 0x12, 0);
			OPMAP[DP4] = new OpCode(DP4, 3, 0x13, 0);
			OPMAP[ABS] = new OpCode(ABS, 2, 0x14, 0);
			OPMAP[NEG] = new OpCode(NEG, 2, 0x15, 0);
			OPMAP[SAT] = new OpCode(SAT, 2, 0x16, 0);
			OPMAP[M33] = new OpCode(M33, 3, 0x17, OP_SPECIAL_MATRIX);
			OPMAP[M44] = new OpCode(M44, 3, 0x18, OP_SPECIAL_MATRIX);
			OPMAP[M34] = new OpCode(M34, 3, 0x19, OP_SPECIAL_MATRIX);
			OPMAP[IFZ] = new OpCode(IFZ, 1, 0x1a, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[INZ] = new OpCode(INZ, 1, 0x1b, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[IFE] = new OpCode(IFE, 2, 0x1c, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[INE] = new OpCode(INE, 2, 0x1d, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[IFG] = new OpCode(IFG, 2, 0x1e, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[IFL] = new OpCode(IFL, 2, 0x1f, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[IEG] = new OpCode(IEG, 2, 0x20, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[IEL] = new OpCode(IEL, 2, 0x21, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[ELS] = new OpCode(ELS, 0, 0x22, OP_NO_DEST | OP_INC_NEST | OP_DEC_NEST);
			OPMAP[EIF] = new OpCode(EIF, 0, 0x23, OP_NO_DEST | OP_DEC_NEST);
			OPMAP[REP] = new OpCode(REP, 1, 0x24, OP_NO_DEST | OP_INC_NEST | OP_SCALAR);
			OPMAP[ERP] = new OpCode(ERP, 0, 0x25, OP_NO_DEST | OP_DEC_NEST);
			OPMAP[BRK] = new OpCode(BRK, 0, 0x26, OP_NO_DEST);
			OPMAP[KIL] = new OpCode(KIL, 1, 0x27, OP_NO_DEST | OP_FRAG_ONLY);
			OPMAP[TEX] = new OpCode(TEX, 3, 0x28, OP_FRAG_ONLY | OP_SPECIAL_TEX);
			OPMAP[SGE] = new OpCode(SGE, 3, 0x29, 0);
			OPMAP[SLT] = new OpCode(SLT, 3, 0x2a, 0);
			OPMAP[SGN] = new OpCode(SGN, 2, 0x2b, 0);
			
			REGMAP[VA] = new Register(VA, "vertex attribute", 0x0, 7, REG_VERT | REG_READ);
			REGMAP[VC] = new Register(VC, "vertex constant", 0x1, 127, REG_VERT | REG_READ);
			REGMAP[VT] = new Register(VT, "vertex temporary", 0x2, 7, REG_VERT | REG_WRITE | REG_READ);
			REGMAP[OP] = new Register(OP, "vertex output", 0x3, 0, REG_VERT | REG_WRITE);
			REGMAP[V] = new Register(V, "varying", 0x4, 7, REG_VERT | REG_FRAG | REG_READ | REG_WRITE);
			REGMAP[FC] = new Register(FC, "fragment constant", 0x1, 27, REG_FRAG | REG_READ);
			REGMAP[FT] = new Register(FT, "fragment temporary", 0x2, 7, REG_FRAG | REG_WRITE | REG_READ);
			REGMAP[FS] = new Register(FS, "texture sampler", 0x5, 7, REG_FRAG | REG_READ);
			REGMAP[OC] = new Register(OC, "fragment output", 0x3, 0, REG_FRAG | REG_WRITE);
			
			SAMPLEMAP[D2] = new Sampler(D2, SAMPLER_DIM_SHIFT, 0);
			SAMPLEMAP[D3] = new Sampler(D3, SAMPLER_DIM_SHIFT, 2);
			SAMPLEMAP[CUBE] = new Sampler(CUBE, SAMPLER_DIM_SHIFT, 1);
			SAMPLEMAP[MIPNEAREST] = new Sampler(MIPNEAREST, SAMPLER_MIPMAP_SHIFT, 1);
			SAMPLEMAP[MIPLINEAR] = new Sampler(MIPLINEAR, SAMPLER_MIPMAP_SHIFT, 2);
			SAMPLEMAP[MIPNONE] = new Sampler(MIPNONE, SAMPLER_MIPMAP_SHIFT, 0);
			SAMPLEMAP[NOMIP] = new Sampler(NOMIP, SAMPLER_MIPMAP_SHIFT, 0);
			SAMPLEMAP[NEAREST] = new Sampler(NEAREST, SAMPLER_FILTER_SHIFT, 0);
			SAMPLEMAP[LINEAR] = new Sampler(LINEAR, SAMPLER_FILTER_SHIFT, 1);
			SAMPLEMAP[CENTROID] = new Sampler(CENTROID, SAMPLER_SPECIAL_SHIFT, 1 << 0);
			SAMPLEMAP[SINGLE] = new Sampler(SINGLE, SAMPLER_SPECIAL_SHIFT, 1 << 1);
			SAMPLEMAP[DEPTH] = new Sampler(DEPTH, SAMPLER_SPECIAL_SHIFT, 1 << 2);
			SAMPLEMAP[REPEAT] = new Sampler(REPEAT, SAMPLER_REPEAT_SHIFT, 1);
			SAMPLEMAP[WRAP] = new Sampler(WRAP, SAMPLER_REPEAT_SHIFT, 1);
			SAMPLEMAP[CLAMP] = new Sampler(CLAMP, SAMPLER_REPEAT_SHIFT, 0);
		}
		
		
		/**
		 * @private
		 * 
		 * @param msg
		 * @param warn
		 */
		private function log(msg:*, warn:Boolean = false):void
		{
			msg = "[AGAL] " + msg;
			if (!warn) HLog.debug(msg);
			else HLog.warn(msg);
		}
	}
}


/**
 * @private
 */
final class OpCode
{
	public var name:String;
	public var nreg:uint;
	public var emit:uint;
	public var flags:uint;
	
	public function OpCode(name:String, nreg:uint, emit:uint, flags:uint)
	{
		this.name = name;
		this.nreg = nreg;
		this.emit = emit;
		this.flags = flags;
	}
}


/**
 * @private
 */
final class Register
{
	public var name:String;
	public var emit:uint;
	public var rang:uint;
	public var flags:uint;
	public var long:String;
	
	public function Register(name:String, long:String, emit:uint, rang:uint, flags:uint)
	{
		this.name = name;
		this.long = long;
		this.emit = emit;
		this.rang = rang;
		this.flags = flags;
	}
}


/**
 * @private
 */
final class Sampler
{
	public var name:String;
	public var flag:uint;
	public var mask:uint;
	
	public function Sampler(name:String, flag:uint, mask:uint)
	{
		this.name = name;
		this.flag = flag;
		this.mask = mask;
	}
}
