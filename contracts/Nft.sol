//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import {Base64} from "./libraries/Base64.sol";

contract Nfts is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><defs><linearGradient id='grad1' x1='0%' y1='0%' x2='100%' y2='0%'><stop offset='0%' style='stop-color:rgb(120,100,35);stop-opacity:1' /><stop offset='100%' style='stop-color:rgb(155,100,180);stop-opacity:1' /></linearGradient></defs><style>.base { fill: 'url(#grad1)'; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='url(#grad1)' /><text x='30%' y='90%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!
    string[] names = [
        "BASTINA",
        "TIRION",
        "HARMIONY",
        "CASPER",
        "LEITO",
        "FRODO",
        "TROILO",
        "AIDAN",
        "FRIDA",
        "ARAODON",
        "CESETH",
        "FOMAR",
        "NIRASH",
        "LILAIN",
        "KAI",
        "NERAGAN",
        "ASOH",
        "QUINO"
    ];
    string[] countries = [
        "-BEL",
        "-BRA",
        "-ING",
        "-ESP",
        "-POR",
        "-ARG",
        "-ALE",
        "-FRA",
        "-ITA",
        "-EEUU",
        "-DIN",
        "-SUI",
        "-MEX",
        "-COL",
        "-URU",
        "-CRO",
        "-HOL",
        "-SUE"
    ];
    string[] thirdWords = [
        "-*",
        "?",
        "--",
        "(-[-)",
        "/",
        ":",
        ";",
        "( - @ - ....)",
        "#",
        "//",
        "|",
        "-|",
        "/_",
        "{}",
        "()",
        "[]",
        "="
    ];

    event NewNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and its symbol.
    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. Woah!");
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % names.length;
        return names[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % countries.length;
        return countries[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getTotal() public view returns (uint256) {
        console.log("TOTAL", _tokenIds.current());
        return _tokenIds.current();
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        require(_tokenIds.current() < 17, "limit is reached");
        uint256 newItemId = _tokenIds.current();

        console.log("current", _tokenIds.current());

        // Actually mint the NFT to the sender using msg.sender.

        // We go and randomly grab one word from each of the three arrays.
        string memory name = pickRandomFirstWord(newItemId);
        string memory countrie = pickRandomSecondWord(newItemId);
        string memory simbol = pickRandomThirdWord(newItemId);

        string memory combined = string(
            abi.encodePacked(name, countrie, simbol)
        );
        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combined, "</text></svg>")
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combined,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");

        console.log(finalTokenUri);
        console.log("--------------------\n");
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewNFTMinted(msg.sender, newItemId);
    }
}
