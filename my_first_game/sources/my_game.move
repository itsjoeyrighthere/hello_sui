module my_first_game::guess_number{
    use std::debug;
    use sui::clock::{Self, Clock};
    use std::string;
    use sui::event;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    

    const EInvalidNumber: u64 = 0;

    struct GameResult has drop,copy{
        your_number: u64,
        computer_number: u64,
        result: string::String
    }
    
    //nft
    struct Sword has key, store {
        id: UID,
        magic: u64,
        strength: u64,
    }

    struct Forge has key, store {
        id: UID,
        swords_created: u64,
    }

    // Part 3: Module initializer to be executed when this module is published
    fun init(ctx: &mut TxContext) {
        let admin = Forge {
            id: object::new(ctx),
            swords_created: 0,
        };
        // Transfer the forge object to the module/package publisher
        transfer::public_transfer(admin, tx_context::sender(ctx));
    }

    // Part 4: Accessors required to read the struct attributes
    public fun magic(self: &Sword): u64 {
        self.magic
    }

    public fun strength(self: &Sword): u64 {
        self.strength
    }

    public fun swords_created(self: &Forge): u64 {
        self.swords_created
    }

    public fun sword_create(magic: u64, strength: u64, recipient: address, ctx: &mut TxContext) {
        use sui::transfer;

        // create a sword
        let sword = Sword {
            id: object::new(ctx),
            magic: magic,
            strength: strength,
        };
        // transfer the sword
        transfer::transfer(sword, recipient);
    }

    public fun sword_transfer(sword: Sword, recipient: address, _ctx: &mut TxContext) {
        use sui::transfer;
        // transfer the sword
        transfer::transfer(sword, recipient);
    }


    

    // number：玩家猜的数字 clock：填0x6，获取以 milliseconds 为单位的时间戳
    public entry fun play(number: u64, clock: &Clock, ctx: &mut TxContext){
        // 玩家输入数字范围应在1-6之间
        assert!(number >= 1 &&number <= 6, EInvalidNumber);
        let computer_number = get_random(6, clock) + 1;
        let resultstr = if (number == computer_number) {
            string::utf8(b"you win :)")
        } else {
            string::utf8(b"you lose :(")
        };
        

        // 结果
        let result = GameResult {
            your_number: number,
            computer_number: computer_number,
            result: resultstr
        };
        event::emit(result);

        //获胜则发给玩家随机sword
        if(number == computer_number){
            let sender = tx_context::sender(ctx);
            let magic = get_random(100,clock);
            let strength = get_random(100,clock);
            sword_create(magic, strength, sender, ctx);
        }
    }

    public fun get_random(max: u64, clock: &Clock):u64{
        let random_value = ((clock::timestamp_ms(clock) % max) as u64);
        debug::print(&random_value);
        random_value
    }
}