//
//  RfidUtil.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 11. 27..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import Foundation


public class RfidUtil
{

	
	/**
	* 태그정보를 정의한 클래스
	* @author 모람씨앤티
	* @version 1.0
	*/
	public class TagInfo
	{
		var mEnuEncoding: Encodings?		/**< 인코딩 종류			*/
		var mStrEpcUrn: String?				/**< EPC URN		*/
		var mStrEpcCode: String?			/**< EPC 코드			*/
		var mStrCorpEpc: String?			/**< 기업EPC코드		*/
		var mStrAssetEpc: String?			/**< 자산EPC코드		*/
		
		var mStrItem: String?				/**< 상품				*/
		var mStrSerialNo: String?			/**< 시리얼번호(제조업체 + 제조년 + 제조월 + 순차번호 로 구성) */
		var mStrLocation: String?			/**< 위치				*/
		var mStrProdCode: String?			/**< 상품코드			*/
		var mStrProdName: String?			/**< 상품명			*/
		var mStrProdReadCnt: String?		/**< 인식수량			*/
		var mStrCustEpc: String?			/**< 고객사EPC			*/
		var mStrYymm: String?				/**< 발행연월 			*/
		var mStrSeqNo: String?				/**< 발행순번			*/
		
		
		
		var mStrAssetName: String?			/**< 자산EPC명 */
		var mBoolNewTag : Bool?
		var mIntReadCount = 0				/**< 조회수 */
		var mStrReadTime : String?
		
		init()
		{
			mEnuEncoding	= nil
			mStrEpcUrn 		= nil
			mStrEpcCode		= nil
			mStrCorpEpc		= nil
			mStrAssetEpc	= nil
			
			mStrItem		= nil
			mStrSerialNo	= nil
			mStrLocation	= nil
			mStrProdCode	= nil
			mStrProdName	= nil
			mStrProdReadCnt	= nil
			mStrCustEpc		= nil
			mStrYymm		= nil
			mStrSeqNo		= nil
			
			mStrAssetName	= nil
			mBoolNewTag		= false
			mIntReadCount	= 0
			mStrReadTime	= nil
		}
		
		/**
		* 인코딩 종류를 리턴한다.
		* @return
		*/
		public func getEncoding() -> Encodings			{ return mEnuEncoding ?? Encodings.GRAI_96			}
		
		/**
		* EPC URN를 리턴한다.
		* @return
		*/
		public func getEpcUrn() -> String				{ return mStrEpcUrn ?? ""			}
		
		/**
		* EPC 코드를 리턴한다.
		* @return
		*/
		public func getEpcCode() -> String				{ return mStrEpcCode ?? ""			}
		
		/**
		* 기업EPC코드를 리턴한다.
		* @return
		*/
		public func getCorpEpc() -> String				{ return mStrCorpEpc ?? ""			}
		
		/**
		* 자산EPC코드를 리턴한다.
		* @return
		*/
		public func getAssetEpc() -> String			{ return mStrAssetEpc ?? ""			}
		
		
		/**
		* 상품을 리턴한다.
		* @return
		*/
		public func getItem() -> String					{ return mStrItem ?? ""			}
		
		/**
		* 시리얼번호를 리턴한다.
		* @return
		*/
		public func getSerialNo() -> String			{ return mStrSerialNo ?? ""			}
		
		/**
		* 위치를 리턴한다.
		* @return
		*/
		public func getLocation() -> String				{ return mStrLocation ?? ""			}
		
		/**
		* 상품코드를 리턴한다.
		* @return
		*/
		public func getProdCode() -> String		{ return mStrProdCode ?? ""		}
		
		/**
		* 상품명을 리턴한다.
		* @return
		*/
		public func getProdName() -> String		{ return mStrProdName ?? ""		}
		
		/**
		* 상품명을 리턴한다.
		* @return
		*/
		public func getProdReadCnt() -> String		{ return mStrProdReadCnt ?? ""		}
		
		/**
		* 고객사EPC를 리턴한다.
		* @return
		*/
		public func getCustEpc() -> String				{ return mStrCustEpc ?? ""			}
		
		/**
		* 발행연월을 리턴한다.
		* @return
		*/
		public func getYymm() -> String				{ return mStrYymm ?? ""				}
		
		/**
		* 발행순번을 리턴한다.
		* @return
		*/
		public func getSeqNo() -> String				{ return mStrSeqNo ?? ""				}
		
		
		
		
		
		// 자산명을 리턴한다.
		public func getAssetName() -> String 		{ return mStrAssetName ?? "" }
		public func getNewTag() -> Bool 			{ return mBoolNewTag ?? false }
		public func getReadCount() -> Int			{ return mIntReadCount 	}
		public func getReadTime() -> String 		{ return mStrReadTime ?? "" }
		
		
		/**
		* 인코딩 종류를 설정한다.
		* @param enuEncoding 인코딩 종류
		*/
		public func setEncoding(enuEncoding: Encodings) 	{ self.mEnuEncoding		= enuEncoding		}
		
		/**
		* EPC URN를 설정한다.
		* @param strEpcUrn EPC URN
		*/
		public func setEpcUrn(strEpcUrn: String)			{ self.mStrEpcUrn		= strEpcUrn		}
		
		/**
		* EPC 코드를 설정한다.
		* @param strEpcCode EPC 코드
		*/
		public func setEpcCode( strEpcCode: String)			{ self.mStrEpcCode		= strEpcCode		}
		
		/**
		* 기업EPC코드를 설정한다.
		* @param strCorpEpc 기업EPC코드
		*/
		public func setCorpEpc( strCorpEpc: String)			{ self.mStrCorpEpc		= strCorpEpc		}
		
		/**
		* 자산EPC코드를 설정한다.
		* @param strAssetEpc 자산EPC코드
		*/
		public func setAssetEpc( assetEpc: String)		{ self.mStrAssetEpc		= assetEpc		}
		

		/**
		* 상품을 설정한다.
		* @param strItem 상품
		*/
		public func setItem( strItem: String)				{ self.mStrItem			= strItem			}
		
		/**
		* 시리얼번호를 설정한다.
		* @param strSerialNo 시리얼번호
		*/
		public func setSerialNo( strSerialNo: String)		{ self.mStrSerialNo		= strSerialNo		}
		
		/**
		* 위치를 설정한다.
		* @param strLocation 위치
		*/
		public func setLocation( strLocation: String)		{ self.mStrLocation		= strLocation		}
		
		/**
		* 상품코드를 설정한다.
		* @param strProdCode
		*/
		public func setProdCode( strProdCode: String)	{ self.mStrProdCode		= strProdCode	}
		
		/**
		* 상품명을 설정한다.
		* @param strProdName
		*/
		public func setProdName( strProdName: String)	{ self.mStrProdName		= strProdName	}
		
		/**
		* 인식수량을 설정한다.
		* @param strProdReadCnt
		*/
		public func setProdReadCnt( strProdReadCnt: String)	{ self.mStrProdReadCnt		= strProdReadCnt	}
		
		/**
		* 고객사EPC를 설정한다.
		* @param strCustEpc 고객사EPC
		*/
		public func setCustEpc(strCustEpc: String)			{ self.mStrCustEpc		= strCustEpc		}
		
		/**
		* 발행연월를 설정한다.
		* @param strYymm 발행연월
		*/
		public func setYymm(strYymm: String)				{ self.mStrYymm			= strYymm			}
		
		/**
		* 발행순번을 설정한다.
		* @param strSeqNo 발행순번
		*/
		public func setSeqNo(strSeqNo: String)				{ self.mStrSeqNo		= strSeqNo			}
		public func setAssetName( assetName: String)	    { self.mStrAssetName = assetName }
		public func setNewTag(newTag: Bool)				    { self.mBoolNewTag = newTag }
		public func setReadCount(readCount: Int)		    { self.mIntReadCount = readCount }
		public func setReadTime(readTime: String)		    { self.mStrReadTime = readTime }
	}
	
	/**
	* 인코딩 종류
	* @author 용민
	*
	*/
	public enum Encodings
	{
		case GID_96, SGTIN_96, SSCC_96, SGLN_96, GRAI_96, GIAI_96, DoD_96, Raw
	}
    
    
    /**
     * 데이터의 헤더를 체크하여 인코딩 타입을 리턴한다.
     * @param strData    데이터
     * @return
     */
    public static func checkHeader(strData: String) -> Encodings
    {
    
    
    
//        /*현님테스트*/System.out.println("============================");
//        /*현님테스트*/System.out.println("====String:"+ strData.substring(0, 2));          //33
//        /*현님테스트*/BigInteger arbData111 = new java.math.BigInteger(strData.substring(0, 2), 16);
//        /*현님테스트*/System.out.println("====arbData111:"+ arbData111);                   //51
//
//        byte[] arbData = new java.math.BigInteger(strData.substring(0, 2), 16).toByteArray();
//
//        String str2 = new String(arbData);
//        System.out.println("====str2:"+ str2);
//
//        /*현님테스트*/System.out.println("====arbData.length:"+ arbData.length);
//
//        String strHeader = Integer.toBinaryString(arbData[0]);
//        /*현님테스트*/System.out.println("====strHeader:"+ strHeader);
//
//
//
//        int intCount = 8 - strHeader.length();
//        /*현님테스트*/System.out.println("====intCount: " + intCount);
//
//        /*현님테스트*/System.out.println("============================");
//
//        for (int intIndex = 0; intIndex < intCount; intIndex++)
//        {
//        strHeader = "0" + strHeader;
//        }
//
//        if (strHeader.startsWith("00101111"))
//        return Encodings.DoD_96;
//        else if (strHeader.startsWith("00110000"))
//        return Encodings.SGTIN_96;
//        else if (strHeader.startsWith("00110001"))
//        return Encodings.SSCC_96;
//        else if (strHeader.startsWith("00110010"))
//        return Encodings.SGLN_96;
//        else if (strHeader.startsWith("00110011"))
//        {
//        /*현님테스트*/System.out.println("====Encodings.GRAI_96=======================");
//        return Encodings.GRAI_96;
//        }
//
//        else if (strHeader.startsWith("00110100"))
//        return Encodings.GIAI_96;
//        else if (strHeader.startsWith("00110101"))
//        return Encodings.GID_96;
//        else
//
        return Encodings.Raw;
    }
    
    
    /**
     * BigInteger
     * @param strData    데이터
     * @return
     */
    struct BigInteger {
        var value: String
        func multiply(right: BigInteger) -> BigInteger {
            var leftCharacterArray = value.reversed().map { Int(String($0))! }
            var rightCharacterArray = right.value.reversed().map { Int(String($0))! }
            var result = [Int](repeating: 0, count: leftCharacterArray.count+rightCharacterArray.count)
            
            for leftIndex in 0..<leftCharacterArray.count {
                for rightIndex in 0..<rightCharacterArray.count {
                    
                    let resultIndex = leftIndex + rightIndex
                    
                    result[resultIndex] = leftCharacterArray[leftIndex] * rightCharacterArray[rightIndex] + (resultIndex >= result.count ? 0 : result[resultIndex])
                    if result[resultIndex] > 9 {
                        result[resultIndex + 1] = (result[resultIndex] / 10) + (resultIndex+1 >= result.count ? 0 : result[resultIndex + 1])
                        result[resultIndex] -= (result[resultIndex] / 10) * 10
                    }
                }
            }
            result = Array(result.reversed())
            return  BigInteger(value: result.map { String($0) }.joined(separator: ""))
        }
    }
	
    
}

