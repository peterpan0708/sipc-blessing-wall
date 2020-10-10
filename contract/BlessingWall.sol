pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
contract BlessingWall {
    struct Pair {
        uint256 value;
        string  content;
        address sender;
    }

    uint256 public total;
    uint256 public max;
    uint256 public period_count;
    uint256 public minimum_bid;
    uint256 public max_content_length = 32;
    uint256 constant top_count = 20;
//    uint256 constant period_top_count = 10;
    uint256 public reset_duration = 7 * 24 *60 * 60;
    uint256 public reset_time;

    event Bidding (address bidder, uint amount, string content);

    Pair [] specialPairs;
    Pair [] pairs;
    Pair [top_count] top_special_pairs;
//    Pair [period_top_count] top_period_pairs;
    Pair first;
    Pair second;
    Pair third;

    address public manager;
    constructor  (address _manager) public {
        manager = _manager;
        max = 500;
        minimum_bid = 10000000000000000;
        reset_time = now + reset_duration;
    }

    function bid (string memory content) public payable {
        if (now > reset_time) {
            reset_time = now + reset_duration;
            period_count = 0;
//            delete top_period_pairs;
//            Pair [period_top_count] storage top_period_pairs;
            first = Pair({value:0,content:"",sender:address (0)});
            second = Pair({value:0,content:"",sender:address (0)});
            third = Pair({value:0,content:"",sender:address (0)});
        }

        require(
            msg.value >= minimum_bid,
            "insufficient amount"
        );
        require(
            period_count + 1 <= max,
            "reach max blessing count"
        );

        require(
            utfStringLength(content) < max_content_length,
            "content to lang"
        );

        total ++;
        period_count ++;
        Pair memory p = Pair({value:msg.value,content:content,sender:msg.sender});
        if (msg.value > minimum_bid) {
            specialPairs.push(p);
            if (top_special_pairs[top_count - 1].value < msg.value) {
                top_special_pairs[top_count - 1] = p;
            }
            for (uint i = top_count - 1; i > 0; i --) {
                if (top_special_pairs[i].value > top_special_pairs[i - 1].value) {
                    Pair memory temp = top_special_pairs[i - 1];
                    top_special_pairs[i - 1] = top_special_pairs[i];
                    top_special_pairs[i] = temp;
                } else {
                    break;
                }
            }
            //为什么这样做不行？
//            if (top_period_pairs[period_top_count - 1].value < msg.value) {
//                top_period_pairs[period_top_count - 1] = p;
//            }
//            for (uint j = period_top_count - 1; j > 0; j --) {
//                if (top_period_pairs[j].value > top_period_pairs[j - 1].value) {
//                    Pair memory temp = top_period_pairs[j - 1];
//                    top_period_pairs[j - 1] = top_period_pairs[j];
//                    top_period_pairs[j] = temp;
//                } else {
//                    break;
//                }
//            }
            //粗暴处理方法
            if (msg.value > third.value) {
                third = p;
                if (third.value > second.value) {
                    Pair memory temp = third;
                    third = second;
                    second = temp;
                    if (second.value > first.value) {
                        Pair memory temp = second;
                        second = first;
                        first = temp;
                    }
                }
            }
        } else {
            pairs.push(p);
        }
        emit Bidding(msg.sender, msg.value, content);
    }

    function set_max (uint max_value) public {
        require(
            msg.sender ==  manager,
            "only manager can set max value"
        );

        max = max_value;
    }

    function set_minimum_bid_value (uint minimum_bid_value) public {
        require(
            msg.sender ==  manager,
            "only manager can set minimum bid value"
        );

        minimum_bid = minimum_bid_value;
    }

    function set_reset_duration (uint reset_duration_value) public {
        require(
            msg.sender ==  manager,
            "only manager can set reset duration value"
        );

        reset_duration = reset_duration_value;
    }

    function set_max_content_length (uint max_content_length_value) public {
        require(
            msg.sender ==  manager,
            "only manager can set reset duration value"
        );

        max_content_length = max_content_length_value;
    }

    function get_pairs_length () external view returns (uint) {
        return pairs.length;
    }

    function get_special_pairs_length () external view returns (uint) {
        return specialPairs.length;
    }

//    function get_top_special_pairs_length () external view returns (uint) {
//        return top_special_pairs.length;
//    }

    function get_pairs (uint size) external view returns (Pair [] memory) {
        uint len  = pairs.length;
        if (size > len) {
            size = len;
        }
        Pair[] memory p = new Pair[](size);
        for (uint i = 0; i < size; i++) {
            p[i] = pairs[len - i - 1];
        }
        return p;
    }

    function get_special_pairs(uint size) external view returns (Pair [] memory) {
        uint len  = specialPairs.length;
        if (size > len) {
            size = len;
        }
        Pair[] memory p = new Pair[](size);
        for (uint i = 0; i < size; i++) {
            p[i] = specialPairs[len - i - 1];
        }
        return p;
    }

    function get_top_special_pairs() external view returns (Pair [] memory) {
        uint len  = top_special_pairs.length;
        Pair[] memory p = new Pair[](len);
        for (uint i = 0; i < len; i++) {
            p[i] = top_special_pairs[i];
        }
        return p;
    }

//    function get_top_period_pairs() external view returns (Pair [] memory) {
//        uint len  = top_period_pairs.length;
//        Pair[] memory p = new Pair[](len);
//        for (uint i = 0; i < len; i++) {
//            p[i] = top_period_pairs[i];
//        }
//        return p;
//    }

    function get_top_period_pairs() external view returns (Pair [] memory) {
        Pair[] memory p = new Pair[](3);
        p[0] = first;
        p[1] = second;
        p[2] = third;
        return p;
    }

//    function get_content_length (string memory content) external view returns (uint) {
//        return utfStringLength(content);
//    }

    function utfStringLength(string memory str) internal pure returns (uint) {
        uint i=0;
        bytes memory string_rep = bytes(str);
        uint length;
        while (i<string_rep.length)
        {
            if (string_rep[i]>>7==0)
                i+=1;
            else if (string_rep[i]>>5==0x06)
                i+=2;
            else if (string_rep[i]>>4==0x0E)
                i+=3;
            else if (string_rep[i]>>3==0x1E)
                i+=4;
            else
                i+=1;

            length++;
        }
        return length;
    }
}